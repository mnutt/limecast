# == Schema Information
# Schema version: 20090421203934
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
#  clean_url              :string(255)   
#

class Episode < ActiveRecord::Base
  belongs_to :podcast

  has_attached_file :thumbnail,
    :whiny_thumbnails => true,
    :url    => "/:attachment/:id/:style/:basename.:extension",
    :path   => ":rails_root/public/:attachment/:id/:style/:basename.:extension",
    :styles => { :square => ["85x85#", :png],
                 :small  => ["170x170#", :png] }

  has_many :reviews, :dependent => :destroy
  has_many :reviewers, :through => :reviews
  has_many :sources, :dependent => :destroy, :include => [:feed], :order => "feeds.bitrate ASC, sources.format ASC"
  has_one :primary_source, :class_name => "Source", :conditions => '`sources`.`feed_id` = #{podcast.primary_feed_id || 0}'

  validates_presence_of :podcast_id, :published_at

  before_create :generate_url

  named_scope :with_same_title_as, lambda {|who| {:conditions => {:podcast_id => who.podcast.id, :clean_url => who.clean_url}} }
  named_scope :without, lambda {|who| (who.nil?||who.id.nil?) ? {} : {:conditions => ["episodes.id NOT IN (?)", who.id]} }
  named_scope :newest, lambda {|*count| {:limit => (count[0] || 1), :order => "published_at DESC"} }
  named_scope :oldest, lambda {|*count| {:limit => (count[0] || 1), :order => "published_at ASC"} }
  named_scope :after,  lambda {|other| {:conditions => ["published_at > ?", other.published_at]} }
  named_scope :before, lambda {|other| {:conditions => ["published_at < ?", other.published_at]} }
  named_scope :sorted, {:order => "published_at DESC"}

  define_index do
    indexes :title, :summary

    has :created_at, :podcast_id
  end

  def self.find_by_slug(slug)
    i = self.find_by_clean_url(slug)
    raise ActiveRecord::RecordNotFound if i.nil? || slug.nil?
    i
  end

  def next_episode
    Episode.oldest.after(self).find_by_podcast_id(podcast_id) rescue nil
  end

  def previous_episode
    Episode.newest.before(self).find_by_podcast_id(podcast_id) rescue nil
  end

  def generate_url
    base_title = self.published_at.to_date.to_s(:url)

    iterate(1) do |i|
      self.clean_url = base_title.dup
      self.clean_url << "-#{i}" unless i == 1

      Episode.with_same_title_as(self).without(self).count > 0
    end

    self.clean_url
  end

  def date_title
    self.published_at.to_date
  end

  def audio_source
    self.sources.select{|s| s.format == "mp3"}.first
  end

  def to_param
    clean_url
  end

  def writable_by?(user)
    self.podcast.writable_by?(user)
  end

  def been_reviewed_by?(user)
    reviewers.reload
    !!user && reviewers.count(:conditions => {:id => user.id}) > 0
  end

  def open_for_reviews?
    self.podcast.episodes.newest.first.id == self.id
  end

  # Returns "video" if video is available, "audio" if audio but not video is available, and nil if neither.
  def preview_type
    types = sources.map(&:preview_type)
    return "video" if types.any? { |t| t == 'video' }
    return "audio" if types.any? { |t| t == 'audio' }
    return nil
  end
end
