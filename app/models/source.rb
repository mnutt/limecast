# == Schema Information
# Schema version: 20080922184801
#
# Table name: episodes
#
#  id                     :integer(4)    not null, primary key
#  podcast_id             :integer(4)    
#  summary                :text          
#  enclosure_url          :string(255)   
#  published_at           :datetime      
#  created_at             :datetime      
#  updated_at             :datetime      
#  thumbnail_file_size    :integer(4)    
#  thumbnail_file_name    :string(255)   
#  thumbnail_content_type :string(255)   
#  guid                   :string(255)   
#  enclosure_type         :string(255)   
#  duration               :integer(4)    
#  title                  :string(255)   
#  clean_url              :string(255)   
#  enclosure_size         :integer(4)    
#

class Source < ActiveRecord::Base
  belongs_to :episode

  def magnet_url
    "magnet:?xs=#{self.url}"
  end
end
