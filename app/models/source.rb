# == Schema Information
# Schema version: 20090201232032
#
# Table name: sources
#
#  id                      :integer(4)    not null, primary key
#  url                     :string(255)   
#  type                    :string(255)   
#  guid                    :string(255)   
#  episode_id              :integer(4)    
#  format                  :string(255)   
#  feed_id                 :integer(4)    
#  sha1hash                :string(24)    
#  screenshot_file_name    :string(255)   
#  screenshot_content_type :string(255)   
#  screenshot_file_size    :string(255)   
#  preview_file_name       :string(255)   
#  preview_content_type    :string(255)   
#  preview_file_size       :string(255)   
#  size                    :integer(8)    
#  xml                     :text          
#

class Source < ActiveRecord::Base
  belongs_to :feed
  belongs_to :episode

  has_attached_file :screenshot, :styles => { :square => ["95x95#", :png] }
  has_attached_file :preview
  has_attached_file :torrent

  def file_name?
    !!read_attribute('file_name')
  end

  def file_name
    read_attribute('file_name') || File.basename(self.url)
  end

  def magnet_url
   params = [
     ("xt=urn:sha1:#{self.sha1hash}" if self.sha1hash),
     ("dn=#{self.file_name}" if self.file_name?),
     "xs=#{self.url}"
   ].compact.join("&")

   "magnet:?#{params}"
  end

  def resolution
    [self.width, self.height].join("x") if self.width && self.height
  end

  def primary?
    feed.primary?
  end
end
