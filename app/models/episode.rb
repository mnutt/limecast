# == Schema Information
# Schema version: 20090811161932
#
# Table name: episodes
#
#  id                     :integer(4)    not null, primary key
#  podcast_id             :integer(4)    
#  summary                :text          
#  published_at           :datetime      
#  created_at             :datetime      
#  updated_at             :datetime      
#  thumbnail_file_size    :integer(4)    
#  thumbnail_file_name    :string(255)   
#  thumbnail_content_type :string(255)   
#  duration               :integer(4)    
#  title                  :string(255)   
#  guid                   :string(255)   
#  xml                    :text          
#  archived               :boolean(1)    
#  subtitle               :text(21474836 
#  daily_order            :integer(4)    default(1)
#  published_on           :date          
#

class Episode < ActiveRecord::Base
  belongs_to :podcast

  has_attached_file :thumbnail,
    :whiny_thumbnails => true,
    :url    => "/:attachment/:id/:style/:basename.:extension",
    :path   => ":rails_root/public/:attachment/:id/:style/:basename.:extension",
    :styles => { :square => ["85x85#", :png],
                 :small  => ["170x170#", :png] }

  has_many :sources, :dependent => :destroy
  has_many :sources_with_preview_and_screenshot, :class_name => "Source", 
           :conditions => "sources.preview_file_size IS NOT NULL && sources.preview_file_size > 1023 && sources.screenshot_file_size IS NOT NULL && sources.screenshot_file_size > 0"
  has_one  :newest_source, :class_name => "Source", :order => "sources.published_at DESC"
  has_one  :surf_episode, :dependent => :destroy

  validates_presence_of :podcast_id, :published_at

  named_scope :archived, {:conditions => {:archived => true}}
  named_scope :with_same_title_as, lambda {|who| {:conditions => {:podcast_id => who.podcast.id, :clean_url => who.clean_url}} }
  named_scope :without, lambda {|who| (who.nil?||who.id.nil?) ? {} : {:conditions => ["episodes.id NOT IN (?)", who.id]} }
  named_scope :next, lambda { |e| {
    :conditions => ["(published_on > ? OR (published_on = ? AND daily_order = ?))", e.published_on, e.published_on, e.daily_order + 1],
    :order => "published_at ASC, daily_order ASC"
  } }
  named_scope :previous, lambda { |e| { 
    :conditions => ["(published_on < ? OR (published_on = ? AND daily_order = ?))", e.published_on, e.published_on, e.daily_order - 1], 
    :order => "published_at DESC, daily_order DESC"
  } }
  named_scope :newest, lambda {|*count| {:limit => (count[0] || 1), :order => "published_on DESC, daily_order DESC"} }
  named_scope :oldest, lambda {|*count| {:limit => (count[0] || 1), :order => "published_on ASC, daily_order ASC"} }
  named_scope :sorted, {:order => "daily_order DESC, published_on DESC"}
  named_scope :sorted_by_bitrate_and_format, :include => [:podcast], :order => "podcasts.bitrate ASC, sources.format ASC"

  define_index do
    indexes :title, :summary, :subtitle
    
    has :podcast_id    
    has :published_at
  end

  def self.find_by_slug(slug)
    episode_slug = slug.split('-')
    date         = episode_slug[0..2]
    date[1]      = Date::ABBR_MONTHNAMES.index date[1]
    date         = date.join('-')
    daily_order  = episode_slug[3] || 1

    i = find(:first, :conditions => ["DATE(published_at) = ? AND daily_order = ?", date, daily_order.to_i])
    raise ActiveRecord::RecordNotFound if i.nil? || slug.nil?
    i
  end

  def next_episode
    podcast.episodes.next(self).find(:first) rescue nil
  end

  def previous_episode
    podcast.episodes.previous(self).find(:first) rescue nil
  end
  
  def clean_url
    daily_order > 1 ? "#{published_at.to_date.to_s(:url)}-#{daily_order}" : published_at.to_date.to_s(:url) unless published_at.nil?
  end
  
  def date_title
    daily_order > 1 ? "#{published_at.to_date.to_s(:title)} (#{daily_order})" : published_at.to_date.to_s(:title) unless published_at.nil?
  end
  
  # def generate_date_title
  #   self.date_title = published_at.to_date.to_s(:title)
  #   self.date_title = date_title + " (2)" if podcast.episodes.exists?(["date_title = ? AND id != ?", date_title, id.to_i])
  #   self.date_title.increment!(" (%s)", 2) while podcast.episodes.exists?(["date_title = ? AND id != ?", date_title, id.to_i])
  #   date_title
  # end

  # def generate_url
  #   self.clean_url = 
  #   self.clean_url += "-2" if podcast.episodes.exists?(["clean_url = ? AND id != ?", clean_url, id.to_i])
  #   self.clean_url.increment!("-%s", 2) while podcast.episodes.exists?(["clean_url = ? AND id != ?", clean_url, id.to_i])
  #   clean_url
  # end

  def diagnostic_xml
    doc = Hpricot.XML(xml.to_s)
    PrettyPrinter.indent_xml(doc)
  end

  def audio_source
    self.sources.select{|s| s.extension == "mp3"}.first
  end

  def to_param
    clean_url
  end

  def writable_by?(user)
    self.podcast.writable_by?(user)
  end

  # Returns "video" if video is available, "audio" if audio but not video is available, and nil if neither.
  def preview_type
    types = sources.map(&:preview_type)
    return "video" if types.any? { |t| t == 'video' }
    return "audio" if types.any? { |t| t == 'audio' }
    return nil
  end
end
