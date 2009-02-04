# == Schema Information
# Schema version: 20090201232032
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
  has_many :reviews, :through => :episodes

  has_many :recommendations, :order => 'weight DESC'
  has_many :recommended_podcasts, :through => :recommendations, :source => :related_podcast

  has_many :taggings, :dependent => :destroy, :include => :tag
  has_many :tags, :through => :taggings, :order => 'name ASC'
  has_many :badges, :source => :tag, :through => :taggings, :conditions => {:badge => true}, :order => 'name ASC'

  accepts_nested_attributes_for :feeds, :allow_destroy => true, :reject_if => proc { |attrs| attrs['url'].blank? }

  has_attached_file :logo,
                    :styles => { :square => ["85x85#", :png],
                                 :small  => ["170x170#", :png],
                                 :large  => ["300x300>", :png],
                                 :icon   => ["16x16#", :png] }

  named_scope :older_than, lambda {|date| {:conditions => ["podcasts.created_at < (?)", date]} }
  named_scope :parsed, lambda {
    { :conditions => { :id => Feed.parsed.map(&:podcast_id).uniq } }
  }
  named_scope :tagged_with, lambda { |*tags|
    # NOTE this does an OR search on the tags; needs to be refactored if all podcasts will include *all* tags
    # TODO This named_scope could definitely be simplified and optimized with some straight SQL
    tags = [tags].flatten.map { |t| Tag.find_by_name(t) }.compact
    podcast_ids = tags.map { |t| t.podcasts.map(&:id) }.flatten.uniq
    { :conditions => { :id => podcast_ids } }
  }
  named_scope :sorted, :order => "REPLACE(title, 'The ', '')"

  attr_accessor :has_episodes
  attr_accessor_with_default :messages, HashWithIndifferentAccess.new

  before_save :attempt_to_find_owner
  before_save :sanitize_titles
  before_save :cache_custom_title
  before_save :sanitize_url

  # Search
  define_index do
    indexes :title, :site, :description, :owner_name, :owner_email
    indexes owner.login, :as => :owner
    indexes episodes.title, :as => :episode_title
    indexes episodes.summary, :as => :episode_summary
    indexes feeds.url, :as => :feed_url
    indexes tags.name, :as => :tag # includes badges

    has taggings.tag_id, :as => :tagged_ids
    has :created_at
  end

  def found_by
    feeds.first.finder rescue nil
  end
  
  def owned_by
    owner
  end
  
  def is_favorite_of?(user)
    user && user.favorite_podcasts.include?(self)
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

  # Takes a string of space-delimited tags and tries to add them to the podcast's taggings.
  # Also takes an additional user argument, which will add a UserTagging to join the Tagging 
  # with a User (to see which users added which tags).
  def tag_string=(*args)
    args.flatten!
    v, user = args

    v.split.each do |tag_name|
      t = Tag.find_by_name(tag_name) || Tag.create(:name => tag_name)
      self.tags << t unless self.tags.include?(t)

      if user && user.is_a?(User)
        tagging = taggings.find_by_tag_id(t.id)
        tagging.users << user rescue nil
      end
    end
  end

  def tag_string
    self.tags.map(&:name).join(" ")
  end

  protected

  def add_message(col, msg)
    # TODO this could probably be a one-liner
    self.messages[col] ||= []
    self.messages[col] << msg
#    self.messages[col].uniq!
  end


  def sanitize_titles
    return if self.title.nil?

    # First, sanitiaze "title"
    self.title.gsub!(/\(.*\)/, "") # Remove anything in parentheses
    self.title.sub!(/^[\s]*-/, "") # Remove leading dashes
    self.title.strip! # Remove leading and trailing space

    i = 1 # Number to attach to the end of the title to make it unique
    while(Podcast.exists?(["title = ? AND id != ?", title, id]))
      self.title.chop!.chop! unless i == 1
      self.title = "#{title} #{i += 1}"
    end
    add_message :title, "There was another podcast with the same title, so we have suggested a new title." if title_changed?

    return title if new_record? # pass custom_title on to cache_custom_title() if this is a new record

    # Second, sanitize "custom_title"
    self.custom_title.gsub!(/\(.*\)/, "") # Remove anything in parentheses
    self.custom_title.sub!(/^[\s]*-/, "") # Remove leading dashes
    self.custom_title.strip! # Remove leading and trailing space

    i = 1 # Number to attach to the end of the title to make it unique
    while(Podcast.exists?(["custom_title = ? AND id != ?", custom_title, id]))
      self.custom_title.chop!.chop! unless i == 1
      self.custom_title = "#{custom_title} #{i += 1}"
    end
    add_message :custom_title, "There was another podcast with the same title, so we have suggested a new title." if custom_title_changed?

    return title
  end

  def cache_custom_title
    self.custom_title = custom_title.blank? ? title : custom_title
  end

  def sanitize_url
    if !self.title.nil? && (custom_title.blank? || custom_title_changed?)

      self.clean_url = self.custom_title.clone.strip # Remove leading and trailing spaces
      self.clean_url.gsub!(/[^A-Za-z0-9\s]/, "")     # Remove all non-alphanumeric non-space characters
      self.clean_url.gsub!(/[\s]+/, '-')             # Condense spaces and turn them into dashes

      add_message :url, "The podcast url has changed." if clean_url_changed?

      self.clean_url
    end
  end

  def attempt_to_find_owner
    self.owner = User.find_by_email(self.owner_email)
    true
  end
end
