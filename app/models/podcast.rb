# == Schema Information
# Schema version: 20090306193031
#
# Table name: podcasts
#
#  id                   :integer(4)    not null, primary key
#  original_title       :string(255)
#  site                 :string(255)
#  logo_file_name       :string(255)
#  logo_content_type    :string(255)
#  logo_file_size       :string(255)
#  created_at           :datetime
#  updated_at           :datetime
#  description          :text
#  language             :string(255)
#  category_id          :integer(4)
#  clean_url            :string(255)
#  owner_id             :integer(4)
#  owner_email          :string(255)
#  owner_name           :string(255)
#  title                :string(255)
#  primary_feed_id      :integer(4)
#  has_previews         :boolean(1)    default(TRUE)
#  has_p2p_acceleration :boolean(1)    default(TRUE)
#  approved             :boolean(1)
#

require 'paperclip_file'

class Podcast < ActiveRecord::Base

  belongs_to :owner, :class_name => 'User'
  belongs_to :category
  belongs_to :primary_feed, :class_name => 'Feed'
  has_many :favorites, :dependent => :destroy
  has_many :favoriters, :source => :user, :through => :favorites

  has_many :feeds, :include => :first_source,#:dependent => :destroy,
           :after_add => :set_primary_feed, :after_remove => :set_primary_feed,
           :group => "feeds.id", :order => "sources.format ASC, feeds.bitrate ASC"
  has_many :episodes, :order => "published_at DESC", :dependent => :destroy
  has_many :reviews, :through => :episodes

  has_many :recommendations, :order => 'weight DESC'
  has_many :recommended_podcasts, :through => :recommendations, :source => :related_podcast

  has_many :taggings, :dependent => :destroy, :include => :tag, :order => 'tags.name ASC'
  has_many :tags, :through => :taggings, :order => 'tags.name ASC'
  has_many :badges, :source => :tag, :through => :taggings, :conditions => {:badge => true}, :order => 'name ASC'

  accepts_nested_attributes_for :feeds, :allow_destroy => true, :reject_if => proc { |attrs| attrs['url'].blank? }

  has_attached_file :logo,
                    :path => ":rails_root/public/:attachment/:id/:style/:basename.:extension",
                    :url  => "/:attachment/:id/:style/:basename.:extension",
                    :styles => { :square => ["85x85#", :png],
                                 :small  => ["170x170#", :png],
                                 :large  => ["300x300>", :png],
                                 :icon   => ["25x25#", :png] }

  named_scope :not_approved, :conditions => {:approved => false}
  named_scope :approved, :conditions => {:approved => true}
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

  attr_accessor :has_episodes, :last_changes
  attr_accessor_with_default :messages, []

  before_validation :sanitize_title
  before_validation :sanitize_url
  before_save :find_or_create_owner
  before_save :set_primary_feed
  before_save :store_last_changes

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

  def self.find_by_slug(slug)
    i = self.find_by_clean_url(slug)
    raise ActiveRecord::RecordNotFound if i.nil? || slug.nil?
    i
  end

	def blacklist!
		self.feeds.each do |f|
			Blacklist.create(:domain => f.url)
			f.update_attributes(:state => "blacklisted")
		end

		self.destroy
	end

  def most_recent_episode
    self.episodes.newest.first
  end

  def related_podcasts
    Recommendation.for_podcast(self).by_weight.first(5).map(&:related_podcast)
  end

  def found_by
    feeds.first.finder rescue nil
  end

  def owned_by
    owner
  end

  def favorite_of?(user)
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
  rescue OpenURI::HTTPError
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
    self.feeds.map { |f| f.finder }.compact
  end

 # An array of users that tagged this podcast
 def taggers
   taggings.map { |t| t.users }.flatten.compact.uniq
 end

  # An array of users that may edit this podcast
  def editors
    @editors ||= (User.admins.all + finders + [owner]).flatten.compact.uniq.reject { |u| u.passive? }
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
        tagging.users << user unless tagging.users.include?(user)
      end
    end
  end

  def tag_string
    self.tags.map(&:name).join(" ")
  end

  # These are additional badges that we don't keep as Tag/Taggings
  def additional_badges(reload=false)
    return @additional_badges if @additional_badges && !reload

    @additional_badges = returning [] do |ab|
      ab << language unless language.blank?

      if e = episodes.newest[0]
        ab << 'current' if e.published_at > 30.days.ago
        ab << 'stale'   if e.published_at <= 30.days.ago && e.published_at > 90.days.ago
        ab << 'archive' if e.published_at <= 90.days.ago
      end
    end
  end

  protected
  def add_message(msg)
    # TODO this could probably be a one-liner
    # TODID i will verify that making this method a one-liner is possible
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
    return true if (!self.owner_id.blank? || self.owner_email.blank?) && !self.owner_email_changed?

    if self.owner = User.find_by_email(owner_email)
      # don't do anything
    else
      owner_login = owner_email.blank? ? "user" : owner_email.to_s.gsub(/[^A-Za-z0-9\s]/, "")[0..39]
      while User.exists?(:login => owner_login) do
        i ||= 1
        owner_login.chop! unless i == 1
        owner_login = "#{owner_login}#{i += 1}"
      end

      o = build_owner(:state => 'passive', :email => owner_email, :login => owner_login)
      o.generate_reset_password_code
      o.save!
      self.owner = o

      UserMailer.deliver_claim_podcast(owner, self)
    end

    true
  end

  # Making obj anonymous because this can be callback'ed for Podcast and Feed (from the association)
  def set_primary_feed(obj=nil)
    if primary_feed_id.blank? && feeds.size > 0
      self.primary_feed_id = feeds.first.id
    end
  end

  # Rails dirty objects stores the current changes only until the object is saved
  def store_last_changes
    @last_changes = changes
  end

end
