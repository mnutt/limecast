class Statistic < ActiveRecord::Base
  named_scope :by_month_and_year, :group => "DATE_FORMAT(created_at,'%b %y')", :order => :created_at
end
