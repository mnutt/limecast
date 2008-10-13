# == Schema Information
# Schema version: 20081010205531
#
# Table name: sources
#
#  id         :integer(4)    not null, primary key
#  url        :string(255)   
#  type       :string(255)   
#  guid       :string(255)   
#  size       :integer(4)    
#  episode_id :integer(4)    
#

class Source < ActiveRecord::Base
  belongs_to :episode

  def magnet_url
    "magnet:?xs=#{self.url}"
  end
end
