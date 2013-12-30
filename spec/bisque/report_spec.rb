require 'spec_helper'

describe Bisque::Report do
  describe "class methods" do
    describe "query" do
      it "should return the query specified in the class" do
        FooReport.query.should == "SELECT * FROM frobnitzs"
        BarReport.query.should == "SELECT * FROM frobnitzs WHERE name = :corn"
      end

      it "should raise a Bisque::MissingQueryException if no query is defined" do
        lambda { NoQueryReport.query }.should raise_error Bisque::MissingQueryException
      end
    end

    describe "params" do
      it "should return an empty array if no parameters exist" do
        FooReport.params.should be_a Array
        FooReport.params.should be_empty
      end

      it "should return a list of the parameters extracted from the query if present" do
        FooReport.params.should be_a Array
        BarReport.params.length.should == 1
        BarReport.params.should include :corn
      end
    end

    describe "method_params" do
      it "should return an empty array if no method parameters exist" do
        FooReport.method_params.should be_a Array
        FooReport.method_params.should be_empty
      end

      it "should return a list of the method parameters extracted from the query if present" do
        CorkReport.method_params.should be_a Array
        CorkReport.method_params.length.should == 1
        CorkReport.method_params.should include :slam
      end
    end

    describe "defaults" do
      it "should return an empty hash if no defaults exist" do
        BarReport.defaults.should be_a Hash
        BarReport.defaults.should be_empty
      end

      it "should return an empty hash of default values specified by the defaults class method" do
        BazReport.defaults.should be_a Hash
        BazReport.defaults[:corn].should == 'hat'
      end

      it "should return an empty hash of default values specified by the default class method" do
        QuuxReport.defaults.should be_a Hash
        QuuxReport.defaults[:slip].should == 'paper'
      end
    end

    describe "row_class" do
      it "should return Bisque::ReportRow if no rows block is defined" do
        FooReport.row_class.should == Bisque::ReportRow
      end

      it "should return the dynamic class defined by the report's class if a rows block is defined" do
        FunReport.row_class.should == FunReportRow
      end
    end
  end

  describe "behaviors" do
    it "should be Enumerable" do
      FooReport.should include Enumerable
    end
  end

  describe "instance methods" do
    before :all do
      Frobnitz.create :name => 'Howdy',
                      :description => 'Here is some text',
                      :score => 12,
                      :cost => 48.22,
                      :numberish => Math::PI,
                      :timish => Time.now - (60*60*24*3),
                      :summed_at => Time.now + (60*60*24*3),
                      :created_on => Date.new(2012),
                      :boolish => true,
                      :binny => "\x00\x01\x02\x03"
      Frobnitz.create :name => 'Slam',
                      :description => 'Here is some other text',
                      :score => 8,
                      :cost => 12.53,
                      :numberish => Math::E,
                      :timish => Time.now + (60*60*24*3),
                      :summed_at => Time.now - (60*60*24*3),
                      :created_on => Date.new(2011),
                      :boolish => false,
                      :binny => "\x03\x02\x01\x00"
    end

    describe "construction" do
      it "should be constructable with no arguments if the query designates no parameters" do
        lambda { FooReport.new }.should_not raise_error
      end

      it "should be constructable with no arguments if the query designates parameters and defaults therefor" do
        lambda { BazReport.new }.should_not raise_error
      end

      it "should raise a Bisque::MissingParameterException if the query designates parameters but no defaults, and it is constructed with no arguments" do
        lambda { BarReport.new }.should raise_error Bisque::MissingParameterException
      end

      it "should raise a Bisque::MissingParameterException if the query designates method parameters but no corresponding methods" do
        lambda { CorkReport.new }.should raise_error Bisque::MissingParameterException
      end

      it "should not raise a Bisque::MissingParameterException if the query designates parameters but no defaults, it is constructed with no arguments, and the designated parameters are designated as optional" do
        lambda { CornReport.new }.should_not raise_error
      end

      it "should not raise a Bisque::MissingParameterException if the query designates method parameters with corresponding methods" do
        lambda { CheeseReport.new }.should_not raise_error Bisque::MissingParameterException
      end

      it "should accept a hash of parameters" do
        lambda { BarReport.new :corn => 'cheese' }.should_not raise_error
      end
    end

    describe "to_s" do
      it "should return the name of the class and a count of resulting rows" do
        f = FooReport.new
        f.to_s.should == 'FooReport: 2 results'
      end
    end

    describe "each" do
      it "should return an enumerator of the results if called without a block" do
        f = FooReport.new
        e = f.each
        e.should be_a Enumerator
        e.count.should == 2
      end

      it "should loop over the results, passing each result to the block if called with a block" do
        f = FooReport.new
        i = 0
        f.each do |r|
          i += 1
        end
        i.should == 2
      end
    end

    describe "[]" do
      it "should allow array access to the results" do
        f = FooReport.new
        f[0].should be_a Bisque::ReportRow
        f[1].should be_a Bisque::ReportRow
        f[0].should_not == f[1]
      end
    end

    describe "last" do
      it "should return the last result" do
        f = FooReport.new
        f.last.should == f[1]
      end
    end

    describe "params" do
      it "should return the hash of specified parameters if there are no defaults" do
        b = BarReport.new :corn => 'chili'
        b.params.should == {:corn => 'chili'}
      end

      it "should return the hash of defaults overridden with specified parameters if defaults are defind" do
        b = BazReport.new
        b.params.should == {:corn => 'hat'}
        b = BazReport.new :corn => 'powder'
        b.params.should == {:corn => 'powder'}
      end

      it "should return the hash of defaults achieved by calling the proc if the default value is a proc" do
        b = PorkReport.new
        b.params.should == {:slip => 'pasta'}
      end
    end

    describe "sql" do
      it "should return the report's query with the parameters interpolated thereto" do
        p = ParamReport.new :name => 'test',
                            :description => 'testagain',
                            :score => 12,
                            :cost => 34.12,
                            :numberish => 123.35583,
                            :created_at => Time.new(2012,1,1,5,0,0),
                            :timish => Time.new(2012,1,1,6,0,0),
                            :summed_at => Time.new(2012,1,1,7,0,0),
                            :created_on => Date.new(2012,2,1),
                            :boolish => true,
                            :binny => "\x00\x01\x02\x03"
        p.sql.should == "SELECT * FROM frobnitzs WHERE name = 'test' AND description = 'testagain' AND score = 12 AND cost = 34.12 AND numberish = 123.35583 AND created_at = '2012-01-01 05:00:00.000000' AND timish = '2012-01-01 06:00:00.000000' AND summed_at = '2012-01-01 07:00:00.000000' AND created_on = '2012-02-01' AND boolish = 't' AND binny = '' AND chili = 'hahahah'"
      end
    end

    after(:all) do
      Frobnitz.destroy_all
    end
  end
end
