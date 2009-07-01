# == Schema Information
# Schema version: 20090617220532
#
# Table name: sources
#
#  id                       :integer(4)    not null, primary key
#  url                      :string(255)   
#  type                     :string(255)   
#  episode_id               :integer(4)    
#  format                   :string(255)   
#  screenshot_file_name     :string(255)   
#  screenshot_content_type  :string(255)   
#  screenshot_file_size     :string(255)   
#  preview_file_name        :string(255)   
#  preview_content_type     :string(255)   
#  preview_file_size        :string(255)   
#  downloaded_at            :datetime      
#  hashed_at                :datetime      
#  curl_info                :text(16777215 
#  ffmpeg_info              :text(16777215 
#  height                   :integer(4)    
#  width                    :integer(4)    
#  file_name                :string(255)   
#  torrent_file_name        :string(255)   
#  torrent_content_type     :string(255)   
#  torrent_file_size        :string(255)   
#  random_clip_file_name    :string(255)   
#  random_clip_content_type :string(255)   
#  random_clip_file_size    :string(255)   
#  ability                  :integer(4)    default(0)
#  framerate                :string(20)    
#  size_from_xml            :integer(4)    
#  size_from_disk           :integer(4)    
#  sha1hash                 :string(40)    
#  torrent_info             :text(16777215 
#  duration_from_ffmpeg     :integer(4)    
#  duration_from_feed       :integer(4)    
#  extension_from_feed      :string(255)   
#  extension_from_disk      :string(255)   
#  content_type_from_http   :string(255)   
#  content_type_from_disk   :string(255)   
#  content_type_from_feed   :string(255)   
#  published_at             :datetime      
#  podcast_id               :integer(4)    
#  bitrate_from_feed        :integer(4)    
#  bitrate_from_ffmpeg      :integer(4)    
#  created_at               :datetime      
#

class Source < ActiveRecord::Base
  belongs_to :episode
  belongs_to :podcast

  named_scope :stale,    :conditions => ["sources.ability < ?", ABILITY]
  named_scope :sorted, lambda {|*col| {:order => "#{col[0] || 'episodes.published_at'} DESC", :include => :episode} }
  named_scope :with_preview, :conditions => "sources.preview_file_size IS NOT NULL && sources.preview_file_size > 1023"
  named_scope :with_screenshot, :conditions => "sources.screenshot_file_size IS NOT NULL && sources.screenshot_file_size > 0"
  named_scope :sorted_by_bitrate, :include => :podcast, :order => "podcasts.bitrate"

  has_attached_file :screenshot, :styles => { :square => ["95x95#", :png] },
                    :url  => "/:attachment/:id/:style/:basename.:extension",
                    :path => ":rails_root/public/:attachment/:id/:style/:basename.:extension"
  has_attached_file :preview,
                    :url  => "/:attachment/:id/:style/:basename.:extension",
                    :path => ":rails_root/public/:attachment/:id/:style/:basename.:extension"
  has_attached_file :random_clip,
                    :url  => "/:attachment/:id/:style/:basename.:extension",
                    :path => ":rails_root/public/:attachment/:id/:style/:basename.:extension"
  has_attached_file :torrent,
                    :url  => "/:attachment/:to_param.torrent",
                    :path => ":rails_root/public/:attachment/:to_param.torrent"
                    

  def archived?
    episode.archived?
  end
  alias :archived :archived?

  # Only check if we set a :file_name from "update_sources"; the File.basename method
  # might not be reliable because some places use weird urls
  def file_name?
    !read_attribute('file_name').blank?
  end

  def file_name
    read_attribute('file_name') || File.basename(url.to_s)
  end

  def to_param
    podcast_name = episode.podcast.clean_url
    episode_date = episode.clean_url
    bitrate      = podcast.formatted_bitrate 
  
    "#{id}-#{podcast_name}-#{episode_date}-#{bitrate}-#{extension}"
  end
  
  # Note: we'll use this as the defacto format instead of format() because
  # format() is derived from ffmpeg output, which has been wrong in some cases
  def extension
    extension_from_disk.blank? ? extension_from_feed : extension_from_disk
  end

  def magnet_url
   params = [
     ("xt=urn:sha1:#{sha1hash}" unless sha1hash.blank?),
     ("dn=#{file_name}" if file_name?),
     "xs=#{url}"
   ].compact.join("&")

   "magnet:?#{params}"
  end

  def resolution
    [self.width, self.height].join("x") if self.width && self.height
  end

  def size
    self.size_from_disk || self.size_from_xml || 0
  end

  def duration
    if(duration_from_ffmpeg && duration_from_ffmpeg > 0)
      duration_from_ffmpeg
    else
      duration_from_feed || 0
    end
  end

  def formatted_bitrate
    bitrate.to_bitrate.to_s if bitrate and bitrate > 0
  end
  
  def bitrate
    @bitrate ||= if(bitrate_from_ffmpeg && bitrate_from_ffmpeg > 0)
                   bitrate_from_ffmpeg
                 elsif(bitrate_from_feed && bitrate_from_feed > 0)
                   bitrate_from_feed
                 elsif(size > 0 && duration > 0)
                   (((size || 0) * 8) / 1000.0) / duration.to_f
                 else
                   0
                 end.to_i
  end
  
  # Returns "video" if video is available, "audio" if audio but not video is available, and nil if neither.
  def preview_type
    return "video" if %w(mp4 m4v mov flv avi asf).include? format
    return "audio" if !format.blank?
    return nil
  end
end
