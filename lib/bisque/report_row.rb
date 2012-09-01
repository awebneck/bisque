module Bisque
  class ReportRow
    def initialize(hash)
      @fields = hash
      hash.keys.each do |k|
        unless self.respond_to? k
          self.singleton_class.send(:define_method, k) { @fields[k] }
        end
      end
    end
  end
end
