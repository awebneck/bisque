class Frobnitz < ActiveRecord::Base
end

class NoQueryReport < Bisque::Report
end

class FooReport < Bisque::Report
  query "SELECT * FROM frobnitzs"
end

class FooeyReport < Bisque::Report
  query "SELECT * FROM frobnitzs"
  rows do
    def whoop
      'silly'
    end
  end
end

class BarReport < Bisque::Report
  query "SELECT * FROM frobnitzs WHERE name = :corn"
end

class BazReport < Bisque::Report
  query "SELECT * FROM frobnitzs WHERE name = :corn"
  defaults :corn => 'hat'
end

class QuuxReport < Bisque::Report
  query "SELECT * FROM frobnitzs WHERE name = :corn"
  default :slip, 'paper'
end

class PorkReport < Bisque::Report
  query "SELECT * FROM frobnitzs WHERE name = :slip"
  default :slip do 'pasta' end
end

class FunReport < Bisque::Report
  query "SELECT * FROM frobnitzs WHERE name = :corn"
  default :slip, 'paper'
  rows do
    def whoop
      'silly'
    end
  end
end

class CornReport < Bisque::Report
  query "SELECT * FROM frobnitzs WHERE name = :corn"
  optional :corn
end

class ParamReport < Bisque::Report
  query "SELECT * FROM frobnitzs WHERE name = :name AND description = :description AND score = :score AND cost = :cost AND numberish = :numberish AND created_at = :created_at AND timish = :timish AND summed_at = :summed_at AND created_on = :created_on AND boolish = :boolish AND binny = :binny"
end
