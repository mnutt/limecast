 # == Schema Information
# Schema version: 20081126170503
#
# Table name: podcasts
#
#  id                :integer(4)    not null, primary key
#  title             :string(255)
#  site              :string(255)
#  logo_file_name    :string(255)
#  logo_content_type :string(255)
#  logo_file_size    :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  description       :text
#  language          :string(255)
#  category_id       :integer(4)
#  clean_url         :string(255)
#  owner_id          :integer(4)
#  owner_email       :string(255)
#  owner_name        :string(255)
#  custom_title      :string(255)
#  primary_feed_id   :integer(4)
#

require 'paperclip_file'

class Podcast < ActiveRecord::Base
  belongs_to :owner, :class_name => 'User'
  belongs_to :category
  belongs_to :primary_feed, :class_name => 'Feed'
  has_many :favorites, :dependent => :destroy
  has_many :feeds, :dependent => :destroy, :include => :first_source,
           :group => "feeds.id", :order => "sources.format ASC, feeds.bitrate ASC"
  has_many :episodes, :dependent => :destroy

  has_many :recommendations, :order => 'weight DESC'
  has_many :recommended_podcasts, :through => :recommendations, :source => :related_podcast

  has_many :taggings, :dependent => :destroy, :include => :tag
  has_many :tags, :through => :taggings, :order => 'name ASC'

  has_attached_file :logo,
                    :styles => { :square => ["85x85#", :png],
                                 :small  => ["170x170#", :png],
                                 :large  => ["300x300>", :png],
                                 :icon   => ["16x16#", :png] }

  named_scope :older_than, lambda {|date| {:conditions => ["podcasts.created_at < (?)", date]} }
  named_scope :parsed, lambda {
    { :conditions => {:id => Feed.parsed.map(&:podcast_id).uniq } }
  }
  named_scope :tagged_with, lambda {|tag|
    { :conditions => {:id => (Tag.find_by_name(tag).podcasts.map(&:id).uniq rescue [])}}
  }
  named_scope :sorted, :order => "REPLACE(title, 'The ', '')"

  attr_accessor :has_episodes

  before_save :attempt_to_find_owner
  before_save :sanitize_title
  before_save :sanitize_url
  before_save :cache_custom_title

  # Search
  define_index do
    indexes :title, :site, :description, :owner_name, :owner_email
    indexes owner.login, :as => :owner
    indexes episodes.title, :as => :episode_title
    indexes episodes.summary, :as => :episode_summary

    has :created_at
  end

  def download_logo(link)
    file = PaperClipFile.new
    file.original_filename = File.basename(link)

    open(link) do |f|
      return unless f.content_type =~ /^image/

      file.content_type = f.content_type
      file.to_tempfile = with(Tempfile.new('logo')) do |tmp|
        tmp.write(f.read)
        tmp.rewind
        tmp
      end
    end

    self.attachment_for(:logo).assign(file)
  end

  def average_time_between_episodes
    return 0 if self.episodes.count < 2
    time_span = self.episodes.newest.first.published_at - self.episodes.oldest.first.published_at
    time_span / (self.episodes.count - 1)
  end

  def clean_site
    self.site.to_url
  end

  def failed?
    feeds(true).all? { |f| f.failed? }
  end

  def primary_feed_with_default
    update_attribute(:primary_feed_id, feeds.first.id) if primary_feed_id.nil?
    primary_feed_without_default
  end
  alias_method_chain :primary_feed, :default

  def reviews
    Review.for_podcast(self)
  end

  def just_created?
    self.created_at > 2.minutes.ago
  end

  def total_run_time
    self.episodes.sum(:duration) || 0
  end

  def to_param
    clean_url
  end

  def writable_by?(user)
    return false unless user and user.active?
    return true if user.admin?
    user_is_owner?(user) or (owner.nil? && user_is_finder?(user))
  end

  def user_is_owner?(user)
    return false if owner.nil? or user.nil?
    owner.id == user.id
  end

  def user_is_finder?(user)
    self.feeds && self.feeds.map{|f| f.finder_id}.include?(user.id)
  end

  def finders
    self.feeds.map(&:finder).compact
  end

  def tag_string=(v)
    v.split.each do |tag_name|
      t = Tag.find_by_name(tag_name) || Tag.create(:name => tag_name)
      self.tags << t unless self.tags.include?(t)
    end
  end

  def tag_string
    self.tags.map(&:name).join(" ")
  end

  protected

  def sanitize_title
    return if self.title.nil?

    # Remove anything in parentheses
    self.title.gsub!(/\(.*\)/, "")
    # Remove leading dashes
    self.title.sub!(/^[\s]*-/, "")
    # Remove leading and trailing space
    self.title.strip!

    conflict = Podcast.find_by_title(self.title)
    self.title = "#{self.title} 2" if conflict and conflict != self

    i = 2 # Number to attach to the end of the title to make it unique
    while(Podcast.find_by_title(self.title) and conflict != self)
      i += 1
      self.title.chop!
      self.title = "#{self.title}#{i.to_s}"
    end

    self.title
  end

  def sanitize_url
    return if self.title.nil?

    # Remove leading and trailing spaces
    self.clean_url = self.title.clone.strip

    # Remove all non-alphanumeric non-space characters
    self.clean_url.gsub!(/[^A-Za-z0-9\s]/, "")

    # Condense spaces and turn them into dashes
    self.clean_url.gsub!(/[\s]+/, '-')
    self.clean_url
  end

  def cache_custom_title
    self.custom_title = custom_title.blank? ? title : custom_title
  end

  def attempt_to_find_owner
    self.owner = User.find_by_email(self.owner_email)

    true
  end
end
