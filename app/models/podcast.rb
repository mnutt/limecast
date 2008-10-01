# == Schema Information
# Schema version: 20080924035304
#
# Table name: podcasts
#
#  id                :integer(4)    not null, primary key
#  title             :string(255)   
#  site              :string(255)   
#  feed_url          :string(255)   
#  logo_file_name    :string(255)   
#  logo_content_type :string(255)   
#  logo_file_size    :string(255)   
#  created_at        :datetime      
#  updated_at        :datetime      
#  feed_etag         :string(255)   
#  description       :text          
#  language          :string(255)   
#  category_id       :integer(4)    
#  user_id           :integer(4)    
#  clean_url         :string(255)   
#  itunes_link       :string(255)   
#  owner_id          :integer(4)    
#  owner_email       :string(255)   
#  name_param        :string(255)   
#  owner_name        :string(255)   
#  feed_content      :text          
#  state             :string(255)   
#  feed_error        :string(255)   
#  custom_title      :string(255)   
#

class PodcastError < StandardError; end

require 'open-uri'
require 'timeout'
require 'rexml/document'
require 'paperclip_file'

class Podcast < ActiveRecord::Base
  belongs_to :user
  belongs_to :owner, :class_name => 'User'
  belongs_to :category

  has_many :episodes, :dependent => :destroy
  has_attached_file :logo,
                    :styles => { :square => ["85x85#", :png],
                                 :small  => ["170x170#", :png],
                                 :large  => ["600x600>", :png],
                                 :icon   => ["16x16#", :png] }

  named_scope :older_than, lambda {|date| {:conditions => ["podcasts.created_at < (?)", date]} }

  attr_accessor :logo_link, :has_episodes

  validates_uniqueness_of :feed_url

  acts_as_taggable

  acts_as_state_machine :initial => :pending
  state :pending
  state :fetched, :enter => Proc.new { |p| p.retrieve_feed }
  state :parsed, :enter => Proc.new { |p| p.parse_feed }
  state :failed

  event :fetch do
    transitions :from => "pending", :to => "fetched"
  end

  event :parse do
    transitions :from => "fetched", :to => "parsed"
  end

  event :fail do
    transitions :from => ["pending", "fetched"], :to => "failed"
  end

  define_index do
    indexes :title, :site, :description
    indexes user.login, :as => :user
    indexes owner.login, :as => :owner
    indexes episodes.title, :as => :episode_title
    indexes episodes.summary, :as => :episode_summary

    has :created_at, :state
  end

  after_create  :distribute_point, :if => '!user.nil?'

  def async_create
    begin
      fetch!
      raise if self.feed_error
      parse!
    rescue
      fail!
    ensure
      self.save!
    end
  end

  def self.retrieve_feed(url)
    Timeout::timeout(5) do
      OpenURI::open_uri(url) do |f|
        f.read
      end
    end
  end

  def retrieve_feed
    self.feed_content = Podcast.retrieve_feed(self.feed_url)
  rescue Timeout::Error
    self.feed_error = "Not found. (timeout)"
  rescue SocketError
    self.feed_error = "Not found."
  rescue Errno::ENETUNREACH
    self.feed_error = "Not found."
  rescue OpenURI::HTTPError
    self.feed_error = "Not found."
  rescue StandardError => e
    self.feed_error = "Weird server error."
  end

  def parse_feed
    retrieve_podcast_info_from_feed
    retrieve_episodes_from_feed
    download_logo
    sanitize_title
    sanitize_url
  end

  def retrieve_podcast_info_from_feed
    parsed_feed = RPodcast::Feed.new(feed_content)
    self.attributes = {:title => parsed_feed.title,
                       :logo_link => parsed_feed.image,
                       :description => parsed_feed.summary,
                       :language => parsed_feed.language,
                       :owner_email => parsed_feed.owner_email,
                       :owner_name => parsed_feed.owner_name,
                       :site => parsed_feed.link}

    set_owner

    self.save!
  rescue PodcastError => e
    self.feed_error = e.message
    raise PodcastError, self.feed_error
  end

  def set_owner
    self.owner = User.find_by_email(self.owner_email)
  end

  def check_for_feed_error
    self.feed_error = "I can't take feeds from that site! Try again." if Blacklist.find_by_domain($1)
    self.feed_error = "That's not a web address. Try again." unless feed_url =~ /^http:\/\/([^\/]+)\/(.*)/
    raise PodcastError, self.feed_error if self.feed_error
  end

  def average_time_between_episodes
    return 0 if self.episodes.count < 2
    time_span = self.episodes.newest.first.published_at - self.episodes.oldest.first.published_at
    time_span / (self.episodes.count - 1)
  end

  def total_run_time
    self.episodes.sum(:duration) || 0
  end

  def clean_site
    self.site.to_url
  end

  def sanitize_url
    # Remove leading and trailing spaces
    self.clean_url = self.title.clone.strip

    # Remove all non-alphanumeric non-space characters
    self.clean_url.gsub!(/[^A-Za-z0-9\s]/, "")

    # Condense spaces and turn them into dashes
    self.clean_url.gsub!(/[\s]+/, '-')
    self.clean_url
  end

  def sanitize_title
    # Remove anything in parentheses
    self.title.gsub!(/[\s+]\(.*\)/, "")

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

  def title
    (self.custom_title.nil? or self.custom_title.blank?) ? super : self.custom_title
  end

  def comments
    Comment.for_podcast(self)
  end

  def to_param
    clean_url
  end

  def download_logo
    @file = PaperClipFile.new
    open(logo_link) do |f|
      raise SocketError, "file is not an image" unless f.content_type.split("/").first == "image"
      @file.original_filename = File.basename(logo_link)
      @file.to_tempfile = Tempfile.new('logo')
      @file.to_tempfile.write(f.read)
      @file.to_tempfile.rewind
      @file.content_type = f.content_type
      attachment_for(:logo).assign @file
    end
  rescue
    return false
  end

  def just_created?
    self.created_at > 2.minutes.ago
  end

  def retrieve_episodes_from_feed
    parsed_episodes = RPodcast::Episode.parse(feed_content)
    parsed_episodes.each do |parsed_episode|
      episode = self.episodes.find_by_guid(parsed_episode.guid) || self.episodes.new
      episode.attributes = {:summary =>        parsed_episode.summary,
                            :guid =>           parsed_episode.guid,
                            :published_at =>   parsed_episode.published_at,
                            :title =>          parsed_episode.title,
                            :enclosure_type => parsed_episode.enclosure.type,
                            :enclosure_size => parsed_episode.enclosure.size,
                            :enclosure_url =>  parsed_episode.enclosure.url,
                            :duration =>       parsed_episode.duration}
      episode.save
    end
  rescue OpenURI::HTTPError
    puts "#{self.feed_url} not modified, skipping..."
  #rescue StandardError => e
  #  self.feed_error = "Problem retrieving episodes from the feed"
  #  raise PodcastError, self.feed_error
  end

  def writable_by?(user)
    # TODO: refactor
    !!(user and user.active? and ((self.user_id == user.id && !self.owner_id) || self.owner_id == user.id || user.admin?))
  end

  protected

  def distribute_point
    self.user.score += 1
    self.user.save
  end
end
