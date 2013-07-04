module Bisque
  class Report
    include Enumerable

    attr_accessor :params, :sql

    def initialize(params={})
      @params = self.class.defaults.merge params
      @params.each do |k,v|
        @params[k] = v.call if v.is_a?(Proc)
      end
      @sql = self.class.query.dup
      self.class.params.each do |param|
        value = @params[param]
        raise Bisque::MissingParameterException, "Missing parameter :#{param} for construction of #{self.class} - please provide a value for this parameter to the constructor or define a default." if value.nil? && !self.class.optional.include?(param.intern)
        @sql.gsub!(/(?<!:):#{param}/, sanitize_and_sqlize(value))
      end
      @results = ActiveRecord::Base.connection.execute @sql
      extract_datatypes
      construct_converted
    end

    def each
      if block_given?
        @converted.each do |r|
          yield r
        end
      else
        Enumerator.new self, :each
      end
    end

    def [](index)
      @converted[index]
    end

    def last
      @converted.last
    end

    def to_s
      "#{self.class}: #{count} result#{'s' if count != 1}"
    end

    protected
      def sanitize_and_sqlize(value)
        if value.is_a? Array
          "(#{value.map { |v| sanitize_and_sqlize(v) }.join(",")})"
        else
          ActiveRecord::Base.connection.quote(value)
        end
      end

      def extract_datatypes
        sql = "SELECT"
        @results.fields.each_with_index do |f, i|
          sql << " UNION SELECT" if i > 0
          sql << " format_type(#{@results.ftype(i)}, #{@results.fmod(i)}) AS type, #{ActiveRecord::Base.sanitize(f)} AS key"
        end
        typeresults = ActiveRecord::Base.connection.execute(sql)
        @types = {}
        typeresults.to_a.each do |typeresult|
          @types[typeresult['key'].intern] = typeresult['type']
        end
      end

      def construct_converted
        @converted = []
        @results.to_a.each do |r|
          @converted << self.class.row_class.new( r.merge(r) { |k, v| convert_value(k,v) })
        end
      end

      def convert_value(key, value)
        return value if value.nil?
        case @types[key.intern]
        when /integer/
          value.to_i
        when /decimal/
          value.to_f
        when /float/
          value.to_f
        when /numeric/
          value.to_f
        when /precision/
          value.to_f
        when /boolean/
          value == 't'
        when /date/
          Date.parse value
        when /timestamp/
          Time.parse value
        when /bytea/
          ActiveRecord::Base.connection.unescape_bytea(value)
        else
          value.to_s
        end
      end

    class << self
      def default(key, val=nil, &block)
        @defaults ||= {}
        @defaults[key] = val || block
      end

      def defaults(hash=nil)
        if hash
          @defaults ||= {}
          @defaults.merge! hash
        else
          @defaults || {}
        end
      end

      def optional(*keys)
        if keys
          @optionals ||= []
          @optionals = (@optionals + keys).uniq
        else
          @optionals || []
        end
      end

      def query(qstr=nil)
        if qstr
          @qstr = qstr.strip
          @params = qstr.scan(/(?<!:):\w+/).map { |p| p.gsub(/:/,'').intern }
        else
          raise Bisque::MissingQueryException, "Bisque Report #{self} missing query definition." if @qstr.nil?
          @qstr
        end
      end

      def rows(&block)
        if block_given?
          carray = self.to_s.split(/::/)
          carray.last << 'Row'
          @row_class = carray.join('::')
          c =  Class.new(Bisque::ReportRow)
          c.class_eval(&block)
          Object.const_set @row_class, c
        end
      end

      def row_class
        return Bisque::ReportRow if @row_class.nil?
        names = @row_class.split('::')
        names.reduce(Object) do |mod, name|
          mod.const_defined?(name) ? mod.const_get(name) : mod.const_missing(name)
        end
      end

      def params
        @params || []
      end
    end
  end
end
