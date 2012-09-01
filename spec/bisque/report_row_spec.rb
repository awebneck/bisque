require 'spec_helper'

describe Bisque::ReportRow do
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
    it "should be an instance of Bisque::ReportRow if the rows block is undefined" do
      f = FooReport.new
      f.first.should be_a Bisque::ReportRow
    end

    it "should be an instance of the dynamically created Row class if the rows block is defined" do
      f = FooeyReport.new :corn => 'hat'
      f.first.should be_a FooeyReportRow
    end
  end

  describe "instance methods" do
    it "should provide an accessor method for each field in the report" do
      f = FooReport.new
      r = f.first
      r.name.should == 'Howdy'
      r.description.should == 'Here is some text'
      r.score.should == 12
      r.cost.should == 48.22
      ((Math::PI - r.numberish).abs < 0.001).should == true
      r.timish.should_not be_nil
      r.summed_at.should_not be_nil
      r.created_on.should_not be_nil
      r.boolish.should == true
      r.binny.should == "\x00\x01\x02\x03"
    end

    it "should respond to calls defined in the rows block" do
      f = FooeyReport.new :corn => 'hat'
      f.first.whoop.should == 'silly'
    end
  end

  after(:all) do
    Frobnitz.destroy_all
  end
end
