class Statistic < ActiveRecord::Base
  named_scope :by_month_and_year, :select => "*, DATE_FORMAT(created_at, '%b %y')", :group => "DATE_FORMAT(created_at, '%b %y')", :order => :created_at
end
