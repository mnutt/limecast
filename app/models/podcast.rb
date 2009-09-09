# == Schema Information
# Schema version: 20090908160006
#
# Table name: podcasts
#
#  id                :integer(4)    not null, primary key
#  site              :string(255)   
#  created_at        :datetime      
#  updated_at        :datetime      
#  category_id       :integer(4)    
#  clean_url         :string(255)   
#  title             :string(255)   
#  button_installed  :boolean(1)    
#  protected         :boolean(1)    
#  favorites_count   :integer(4)    default(0)
#  url               :string(255)   
#  itunes_link       :string(255)   
#  state             :string(255)   default("pending")
#  bitrate           :integer(4)    
#  finder_id         :integer(4)    
#  format            :string(255)   
#  xml               :text          
#  ability           :integer(4)    default(0)
#  generator         :string(255)   
#  xml_title         :string(255)   
#  description       :text(21474836 
#  language          :string(255)   
#  logo_file_name    :string(255)   
#  logo_content_type :string(255)   
#  logo_file_size    :string(255)   
#  error             :string(255)   
#  custom_title      :string(255)   default("")
#  subtitle          :text(21474836 
#  author_email      :string(255)   
#  author_name       :string(255)   
#

require 'paperclip_file'
require 'open-uri'
require 'timeout'

class Podcast < ActiveRecord::Base
  has_many :recommendations, :order => 'weight DESC'
  has_many :recommended_podcasts, :through => :recommendations, :source => :related_podcast
  has_many :episodes, :dependent => :destroy
  has_many :recent_episodes, :class_name => 'Episode', :conditions => ["published_at > ?", 30.days.ago]
  has_many :reviews, :conditions => "reviews.user_id IS NOT NULL", :dependent => :destroy
  has_many :reviewers, :through => :reviews, :source => :reviewer
  has_many :favorites, :dependent => :destroy
  has_many :favoriters, :source => :user, :through => :favorites
  has_many :taggings, :dependent => :destroy, :include => :tag, :order => 'tags.name ASC'
  has_many :tags, :through => :taggings, :order => 'tags.name ASC'
  has_many :badges, :source => :tag, :through => :taggings, :conditions => {:badge => true}, :order => 'name ASC'
  has_many :sources, :dependent => :destroy
  has_many :alt_urls, :class_name => 'PodcastAltUrl', :dependent => :destroy

  has_one  :newest_episode, :class_name => 'Episode', :order => "published_at DESC"
  has_one  :oldest_episode, :class_name => 'Episode', :order => "published_at ASC"
  has_one  :newest_source, :class_name => 'Source', :include => :episode, :order => "episodes.published_at DESC"
  has_one  :queued_podcast, :dependent => :destroy

  belongs_to :finder, :class_name => 'User'

  has_attached_file :logo,
                    :path => ":rails_root/public/podcast_:attachment/:id/:style/:basename.:extension",
                    :url  => "/podcast_:attachment/:id/:style/:basename.:extension",
                    :styles => { :square  => ["85x85#", :png],
                                 :small   => ["160x160#", :png],
                                 :large   => ["300x300>", :png],
                                 :icon    => ["25x25#", :png],
                                 :favicon => ["16x16#", :ico],
                                 :thumb   => ["16x16#", :png] }

  named_scope :by, lambda { |user_or_author| {:conditions => {:author_email => user_or_author.email}} }
  named_scope :older_than, lambda {|date| {:conditions => ["podcasts.created_at < (?)", date]} }
  named_scope :parsed, :conditions => {:state => 'parsed'}
  named_scope :tagged_with, lambda { |*tags|
    # NOTE this does an OR search on the tags; needs to be refactored if all podcasts will include *all* tags
    # TODO This named_scope could definitely be simplified and optimized with some straight SQL
    tags = [tags].flatten.map { |t| Tag.find_by_name(t) }.compact
    podcast_ids = tags.map { |t| t.podcasts.map(&:id) }.flatten.uniq
    { :conditions => { :id => podcast_ids } }
  }
  named_scope :sorted, :order => "REPLACE(title, 'The ', '')"
  named_scope :popular, :order => "favorites_count DESC"
  named_scope :sorted_by_newest_episode, :include => :newest_episode, :order => "episodes.published_at DESC"
  named_scope :from_limetracker, :conditions => ["podcasts.generator LIKE ?", "%limecast.com/tracker%"]
  named_scope :with_itunes_link, :conditions => 'podcasts.itunes_link IS NOT NULL and podcasts.itunes_link <> ""'
  named_scope :unclaimed, :conditions => "finder_id IS NULL"
  named_scope :claimed, :conditions => "finder_id IS NOT NULL"
  named_scope :found_by_admin, :include => :finder, :conditions => ["users.admin = ?", true]
  named_scope :found_by_nonadmin, :include => :finder, :conditions => ["users.admin = ? OR users.admin IS NULL", false]
  named_scope :sorted_by_bitrate_and_format, :order => "podcasts.bitrate ASC, podcasts.format ASC"
  
  attr_accessor :has_episodes, :last_changes
  attr_accessor_with_default :messages, []

  before_validation :set_title
  before_validation :sanitize_title
  before_validation :sanitize_url
  before_save :store_last_changes
  after_destroy :update_finder_score

  validates_presence_of   :title, :unless => Proc.new { |podcast| podcast.new_record? }
  validates_presence_of   :url
  validates_uniqueness_of :url
  validates_length_of     :url, :maximum => 1024

  # Search
  define_index do
    indexes :title, :site, :description, :author_name, 
            :author_email, :url, :subtitle, :language
    indexes author.name, :as => :author
    indexes episodes.title, :as => :episode_title
    indexes episodes.summary, :as => :episode_summary
    indexes tags.name, :as => :tag # includes badges

    has taggings.tag_id, :as => :tagged_ids
  end

  def self.find_by_slug(slug)
    i = self.find_by_clean_url(slug)
    raise ActiveRecord::RecordNotFound if i.nil? || slug.nil?
    i
  end

  def author
    return nil if author_email.blank?

    @author ||= Author.find_or_initialize_by_email(author_email.to_s.strip) 
    @author.name = author_name if @author.name.blank?
    @author.save 
    @author
  end

  def apparent_format
    sources.first.extension.to_s unless sources.blank?
  end

  def apparent_resolution
    sources.first.resolution unless sources.blank?
  end

  # takes the name of the Podcast url (ie "http://me.com/feeds/quicktime-small" -> "Quicktime Small")
  def apparent_format_long
    url.split("/").last.titleize

    # Uncomment this to get the official format from the Source extension
    # ::FileExtensions::All[apparent_format.intern]
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
  rescue OpenURI::HTTPError => e
  end
  
  
  def diagnostic_xml
    doc = Hpricot.XML(self.xml.to_s)
    doc.search("item").remove
    PrettyPrinter.indent_xml(doc)
  end
  
  def as(type)
    case type
    when :torrent
      self.remixed_as_torrent
    when :magnet
      self.remixed_as_magnet
    when :plain
      self.xml.to_s
    else
      self.xml.to_s
    end
  end
  
  def remix_feed
    xml = self.xml.to_s.dup

    h = Hpricot(self.xml.to_s)
    (h / 'item').each do |item|
      enclosure     = (item % 'enclosure') || {}
      media_content = (item % 'media:content') || {}

      urls = [enclosure['url'], media_content['url']].compact.uniq
      urls.each do |url|
        s = self.sources.find_by_url(url)

        unless s.nil?
          new_url = yield s
          xml.gsub!(url, new_url) unless new_url.nil?
        end
      end
    end

    xml
  end

  # TODO figure out a better way to get the host?
  def remixed_as_torrent
    remix_feed do |s|
      "http://limecast.com" + s.torrent.url if s.torrent?
    end
  end

  def remixed_as_magnet
    remix_feed do |s|
      s.magnet_url
    end
  end
  
  def formatted_bitrate
    bitrate.to_bitrate.to_s if bitrate and bitrate > 0
  end

  def itunes_url
    "http://www.itunes.com/podcast?id=#{itunes_link}"
  end

  def miro_url
    "http://subscribe.getmiro.com/?url1=#{url}"
  end
  
  def been_reviewed_by?(user)
    reviewers.include?(user)
  end
  
  # XXX: Write spec for this
  def blacklist!
    Blacklist.create(:domain => url)
    update_attributes(:state => "blacklisted")
    destroy
  end

  # All taggings that are either badges or tags that have been user_tagging'ed.
  def claimed_taggings
    taggings.all.compact.reject { |t| !t.tag.badge? && t.user_taggings.claimed.empty? }
  end

  # All taggings that are tags that have NOT been user_tagging'ed.
  def unclaimed_taggings
    taggings.all.compact.reject { |t| t.tag.badge? || !t.user_taggings.claimed.empty? }
  end

  # All badges, and tags that have been user_tagging'ed.
  def claimed_tags
    claimed_taggings.map(&:tag)
  end

  # All badges, and tags that have NOT been user_tagging'ed.
  def unclaimed_tags
    unclaimed_taggings.map(&:tag)
  end

  def related_podcasts
    Recommendation.for_podcast(self).by_weight.first(5).map(&:related_podcast)
  end

  def favorite_of?(user)
    user && user.favorite_podcasts.include?(self)
  end

  def average_time_between_episodes
    return 0 if episodes.count < 2
    time_span = newest_episode.published_at - oldest_episode.published_at
    time_span / (episodes.count - 1)
  end

  def clean_site
    site ? site.to_url : ''
  end

  def just_created?
    created_at > 2.minutes.ago
  end

  def total_run_time
    episodes.sum(:duration) || 0
  end

  def to_param
    clean_url
  end

  def to_filename_param(extra=nil)
    extra = "-#{extra}" if extra
    "#{id}-#{clean_url}-#{formatted_bitrate}-#{apparent_format}#{extra}".delete(".")
  end

  def writable_by?(user)
    return true if editors.include?(user)
    return false
  end

  def user_is_author?(user)
    return false if author.nil? or user.nil?
    author.id == user.id
  end

 # An array of users that tagged this podcast
 def taggers
   taggings.map { |t| t.users }.flatten.compact.uniq
 end

  # An array of users that may edit this podcast
  def editors
    return @editors if @editors
    @editors = returning([]) do |e|
      e << User.admins.all
      e << finder if finder && !protected?
      e << author.user if author && author.user
      e.flatten!
      e.compact!
    end
    @editors
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

      if user && user.is_a?(User) && !user.new_record?
        tagging = taggings(true).find_by_tag_id(t.id)
        begin
          tagging.users << user unless tagging.users.include?(user) 
        rescue ActiveRecord::RecordInvalid => e
          puts "\n\n\nerror in tag_string= #{e}\n\n"
        end
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
      ab << language unless language.blank? || language !~ /^[-_a-zA-Z0-9]$/

      if e = episodes.newest[0]
        ab << 'current' if e.published_at > 30.days.ago
        ab << 'stale'   if e.published_at <= 30.days.ago && e.published_at > 90.days.ago
        ab << 'archive' if e.published_at <= 90.days.ago
      end
    end
  end

  def new?
    created_at == updated_at
  end

  def notify_users
    if new?
      PodcastMailer.deliver_new_podcast(self)
    end
  end

  def add_message(msg)
    # TODO this could probably be a one-liner
    # TODID i will verify that making this method a one-liner is possible
    self.messages << msg
  end

  protected
  def set_title
    self.title = custom_title if title.blank? || custom_title_changed?
    self.title = xml_title if title.blank? || (xml_title_changed? && custom_title.blank?)
    self.title = "Untitled" if title.blank?
  end
  
  def sanitize_title
    desired_title = title
    # Second, sanitize "title"
    self.title.sub!(/^[\s]*-/, "") # Remove leading dashes
    self.title.strip!              # Remove leading and trailing space

    # Increment the name until it's unique
    self.title = "#{title} (2)" if Podcast.exists?(["title = ? AND id != ?", title, id.to_i])
    self.title.increment!("(%s)") while Podcast.exists?(["title = ? AND id != ?", title, id.to_i])

    add_message "There was another podcast with the same title, so we have suggested a new title." if title != desired_title

    return title
  end

  def sanitize_url
    if (title.blank? || title_changed?)
      self.clean_url = PermalinkFu.escape_and_preserve_case(title.to_s.clone)
      self.clean_url.gsub!(/[^A-Za-z0-9\s-]/, "")  # Remove all non-alphanumeric non-space non-hyphen characters
      self.clean_url.gsub!(/\s+/, '-')             # Condense spaces and turn them into dashes
      self.clean_url.gsub!(/\-{2,}/, '-')          # Replaces multiple sequential hyphens with one hyphen
      self.clean_url = 'untitled' if clean_url.empty?

      self.clean_url = "#{clean_url}-2" if Podcast.exists?(["clean_url = ? AND id != ?", clean_url, id.to_i])
      self.clean_url.increment! while Podcast.exists?(["clean_url = ? AND id != ?", clean_url, id.to_i])

      add_message "The podcast url has changed." if clean_url_changed?
    end

    return clean_url
  end

  # Rails dirty objects stores the current changes only until the object is saved
  def store_last_changes
    @last_changes = changes
  end

  def update_finder_score
    finder.calculate_score! if finder
  end
end
