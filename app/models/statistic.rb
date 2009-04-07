# == Schema Information
# Schema version: 20090407191118
#
# Table name: statistics
#
#  id                                  :integer(4)    not null, primary key
#  podcasts_count                      :integer(4)    
#  podcasts_found_by_admins_count      :integer(4)    
#  podcasts_found_by_nonadmins_count   :integer(4)    
#  feeds_count                         :integer(4)    
#  feeds_found_by_admins_count         :integer(4)    
#  feeds_found_by_nonadmins_count      :integer(4)    
#  users_count                         :integer(4)    
#  users_active_count                  :integer(4)    
#  users_pending_count                 :integer(4)    
#  users_passive_count                 :integer(4)    
#  reviews_count                       :integer(4)    
#  created_at                          :datetime      
#  feeds_from_trackers_count           :integer(4)    
#  podcasts_with_buttons_count         :integer(4)    
#  podcasts_on_google_first_page_count :integer(4)    
#

class Statistic < ActiveRecord::Base
  named_scope :by_month_and_year, lambda { { :group => "DATE_FORMAT(created_at, '%b %y')", :order => "created_at" } }
end
