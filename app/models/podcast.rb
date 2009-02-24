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
#  title      :string(255)   
#  primary_feed_id   :integer(4)    
#

require 'paperclip_file'

class Podcast < ActiveRecord::Base
  belongs_to :owner, :class_name => 'User'
  belongs_to :category
  belongs_to :primary_feed, :class_name => 'Feed'
  has_many :favorites, :dependent => :destroy
  has_many :favoriters, :source => :user, :through => :favorites

  has_many :feeds, :include => :first_source, :dependent => :destroy,
           :after_add => :set_primary_feed, :after_remove => :set_primary_feed,
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
                                 :icon   => ["25x25#", :png] }

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
  attr_accessor_with_default :messages, []

  before_validation :sanitize_title
  before_validation :sanitize_url
  before_save :find_or_create_owner
  before_save :set_primary_feed

  validates_presence_of   :title, :unless => Proc.new { |podcast| podcast.new_record? }
  validates_format_of     :title, :with => /[A-Za-z0-9]+/, :message => "must include at least 1 letter (a-z, A-Z)"

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

  attr_accessor :has_previews, :has_p2p_acceleration

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
    self.site ? self.site.to_url : ''
  end

  def failed?
    feeds(true).all? { |f| f.failed? }
  end

  def primary_feed_with_default
    set_primary_feed if primary_feed_id.blank?
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
    return false unless user
    return true if user.admin?
    user_is_owner?(user) or user_is_finder?(user)
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
  # Ex: podcast.tag_string = "funny, hilarious"
  # Ex: podcast.tag_string = "animated, kids", current_user
  def tag_string=(*args)
    args.flatten!
    v, user = args

    v.split.each do |tag_name|
      t = Tag.find_by_name(tag_name) || Tag.create(:name => tag_name)
      self.tags << t unless self.tags.include?(t)

      if user && user.is_a?(User)
        tagging = taggings(true).find_by_tag_id(t.id)
        tagging.users << user
      end
    end
  end

  def tag_string
    self.tags.map(&:name).join(" ")
  end

  protected
  def add_message(msg)
    # TODO this could probably be a one-liner
    self.messages << msg
  end

  def sanitize_title
    if new_record?
      self.title = original_title if title.blank? # cache the original_title on create
    end

    desired_title = title
    # Second, sanitize "title"
    self.title.gsub!(/\(.*\)/, "") # Remove anything in parentheses
    self.title.sub!(/^[\s]*-/, "") # Remove leading dashes
    self.title.strip! # Remove leading and trailing space
  
    i = 1 # Number to attach to the end of the title to make it unique
    while(Podcast.exists?(["title = ? AND id != ?", title, id]))
      self.title.chop!.chop! unless i == 1
      self.title = "#{title} #{i += 1}"
    end

    add_message "There was another podcast with the same title, so we have suggested a new title." if title != desired_title

    return title
  end
  
  def sanitize_url
    if (title.blank? || title_changed?)
      self.clean_url = self.title.to_s.clone.strip # Remove leading and trailing spaces
      self.clean_url.gsub!(/[^A-Za-z0-9\s]/, "")     # Remove all non-alphanumeric non-space characters
      self.clean_url.gsub!(/[\s]+/, '-')             # Condense spaces and turn them into dashes

      i = 1 # Number to attach to the end of the title to make it unique
      while(Podcast.exists?(["clean_url = ? AND id != ?", clean_url, id]))
        self.clean_url.chop!.chop! unless i == 1
        self.clean_url = "#{clean_url}-#{i += 1}"
      end
  
      add_message "The podcast url has changed." if clean_url_changed?
    end

    return clean_url
  end

  def find_or_create_owner
    return true unless owner.nil?

    unless self.owner = User.find_by_email(owner_email)
      owner_login = owner_email.to_s.gsub(/[^A-Za-z0-9\s]/, "")
      while User.exists?(:login => owner_login) do
        i ||= 1
        owner_login.chop! unless i == 1
        owner_login = "#{owner.login}#{i += 1}"
      end

      create_owner(:state => 'passive', :email => owner_email, :login => owner_login,
                  :password =>  User.generate_code("The Passive User's Password"))

    end
    save!
    
    true
  end

  # Making obj anonymous because this can be callback'ed for Podcast and Feed (from the association)
  def set_primary_feed(obj=nil)
    if primary_feed_id.blank? && feeds.size > 0
      self.primary_feed_id = feeds.first.id
      save! unless new_record?
    end
  end

end
