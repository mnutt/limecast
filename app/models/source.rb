# == Schema Information
# Schema version: 20090413212224
#
# Table name: sources
#
#  id                       :integer(4)    not null, primary key
#  url                      :string(255)
#  type                     :string(255)
#  guid                     :string(255)
#  episode_id               :integer(4)
#  format                   :string(255)
#  feed_id                  :integer(4)
#  sha1hash                 :string(24)
#  screenshot_file_name     :string(255)
#  screenshot_content_type  :string(255)
#  screenshot_file_size     :string(255)
#  preview_file_name        :string(255)
#  preview_content_type     :string(255)
#  preview_file_size        :string(255)
#  height                   :integer(4)
#  width                    :integer(4)
#  xml                      :text
#  downloaded_at            :datetime
#  hashed_at                :datetime
#  curl_info                :text
#  ffmpeg_info              :text
#  file_name                :string(255)
#  torrent_file_name        :string(255)
#  torrent_content_type     :string(255)
#  torrent_file_size        :string(255)
#  random_clip_file_name    :string(255)
#  random_clip_content_type :string(255)
#  random_clip_file_size    :string(255)
#  ability                  :integer(4)    default(0)
#  archived                 :boolean(1)
#  framerate                :string(20)
#  size_from_xml            :integer(4)
#  size_from_disk           :integer(4)
#

class Source < ActiveRecord::Base
  belongs_to :feed
  belongs_to :episode

  named_scope :stale,    :conditions => ["sources.ability < ?", ABILITY]
  named_scope :approved, lambda { {:conditions => ["episode_id IN (?)", Podcast.approved.map(&:episode_ids).flatten]} }
  named_scope :sorted, lambda {|*col| {:order => "#{col[0] || 'episodes.published_at'} DESC", :include => :episode} }
  named_scope :with_preview, :conditions => "sources.preview_file_size IS NOT NULL && sources.preview_file_size > 1023"
  named_scope :with_screenshot, :conditions => "sources.screenshot_file_size IS NOT NULL && sources.screenshot_file_size > 0"

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
                    :url  => "/:attachment/:id/:style/:basename.:extension",
                    :path => ":rails_root/public/:attachment/:id/:style/:basename.:extension"

  def diagnostic_xml
    doc = Hpricot.XML(self.xml)
    PrettyPrinter.indent_xml(doc)
  end

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

  def torrent_url
    podcast_name = self.episode.podcast.clean_url
    episode_date = self.episode.clean_url
    bitrate      = self.feed.bitrate.to_bitrate.to_s
    format       = read_attribute('format')

    "http://limecast.com/#{podcast_name}/#{episode_date}/#{podcast_name}-#{episode_date}-#{bitrate}-#{format}.torrent"
  end

  def resolution
    [self.width, self.height].join("x") if self.width && self.height
  end

  def primary?
    feed.primary?
  end

  def extension
    file_name.split('.').last
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
  
  # Returns "video" if video is available, "audio" if audio but not video is available, and nil if neither.
  def preview_type
    return "video" if %w(mp4 m4v mov flv avi asf).include? format
    return "audio" if !format.blank?
    return nil
  end
end
