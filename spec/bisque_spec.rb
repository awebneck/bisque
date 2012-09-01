require 'spec_helper'

describe Bisque do
  it "should define the Bisque::Report class" do
    lambda { Bisque::Report }.should_not raise_error
  end
  it "should define the Bisque::ReportRow class" do
    lambda { Bisque::ReportRow }.should_not raise_error
  end
  it "should define the Bisque::MissingQueryException class" do
    lambda { Bisque::MissingQueryException }.should_not raise_error
  end
  it "should define the Bisque::MissingParameterException class" do
    lambda { Bisque::MissingParameterException }.should_not raise_error
  end
end
