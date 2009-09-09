# == Schema Information
# Schema version: 20090908160006
#
# Table name: feed_request_statistics
#
#  id         :integer(4)    not null, primary key
#  feed_type  :string(255)   
#  ip_address :string(255)   
#  user_agent :string(255)   
#  referer    :string(255)   
#  podcast_id :integer(4)    
#  created_at :datetime      
#  updated_at :datetime      
#

class FeedRequestStatistic < ActiveRecord::Base
  belongs_to :podcast
end
