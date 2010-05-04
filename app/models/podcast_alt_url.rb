# == Schema Information
# Schema version: 20100504173954
#
# Table name: podcast_alt_urls
#
#  id         :integer(4)    not null, primary key
#  podcast_id :integer(4)    
#  url        :string(255)   
#  created_at :datetime      
#  updated_at :datetime      
#  bitrate    :integer(4)    
#  size       :integer(4)    
#  extension  :string(255)   
#

class PodcastAltUrl < ActiveRecord::Base
  belongs_to :podcast
  
  def formatted_bitrate
    bitrate.to_bitrate.to_s if bitrate and bitrate > 0
  end
end
