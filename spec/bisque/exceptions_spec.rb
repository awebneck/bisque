require 'spec_helper'

describe "Bisque Exceptions" do
  describe Bisque::MissingQueryException do
    it "should be an Exception" do
      Bisque::MissingQueryException.ancestors.should include Exception
    end
  end
  describe Bisque::MissingParameterException do
    it "should be an Exception" do
      Bisque::MissingQueryException.ancestors.should include Exception
    end
  end
end
