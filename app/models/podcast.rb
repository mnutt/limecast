# == Schema Information
# Schema version: 20080829144522
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
#  clean_title       :string(255)   
#  itunes_link       :string(255)   
#  owner_id          :integer(4)    
#  email             :string(255)   
#  name_param        :string(255)   
#  owner_name        :string(255)   
#  feed_content      :text          
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
  has_many :comments, :as => :commentable, :conditions => "comments.user_id IS NOT NULL", :dependent => :destroy
  has_many :commenters, :through => :comments

  has_many :episodes, :order => "published_at DESC", :dependent => :destroy

  attr_accessor :logo_link, :has_episodes

  validates_uniqueness_of :feed_url

  acts_as_taggable

  has_attached_file :logo,
                    :styles => { :square => ["85x85#", :png],
                                 :small  => ["170x170#", :png],
                                 :icon   => ["16x16#", :png] }

  acts_as_state_machine :initial => :pending
  state :pending
  state :parsed
  state :failed

  before_create :sanitize_title

  async_after_create do |p|
    p.async_after_create
  end

  def async_after_create
    begin
      self.check_for_feed_error
      self.retrieve_feed
      self.retrieve_podcast_info_from_feed
      self.retrieve_episodes_from_feed
      self.download_logo
      self.state = "parsed"
      self.sanitize_title
      self.generate_url
      self.save!
    rescue
      self.state = "failed"
      self.feed_error ||= "There was a problem with the feed"
      self.save!
    end
  end

  # define_index do
  #   indexes :title, :site, :description
  #   indexes user.login, :as => :user
  #   indexes owner.login, :as => :owner
  #   indexes episodes.title, :as => :episode_title
  #   indexes episodes.summary, :as => :episode_summary
  #   indexes comments.title, :as => :comment_title
  #   indexes comments.body, :as => :comment_body

  #   has :created_at, :state
  # end

  named_scope :older_than, lambda {|date| {:conditions => ["podcasts.created_at < (?)", date]} }

  def self.retrieve_feed(url)
    Timeout::timeout(5) do
      OpenURI::open_uri(url) do |f|
        f.read
      end
    end
  rescue Timeout::Error
    self.feed_error = "Not found. (timeout) Try again."
  rescue Errno::ENETUNREACH
    self.feed_error = "Not found. Try again."
  rescue StandardError => e
    self.feed_error = "Weird server error. Try again."
  end

  def retrieve_feed
    self.feed_content = Podcast.retrieve_feed(self.feed_url)
  end

  def retrieve_podcast_info_from_feed
    begin
      doc = REXML::Document.new(feed_content)
    rescue
      raise PodcastError, "There was a problem parsing the feed."
    end

    raise PodcastError, "This is not a podcast feed. Try again." unless REXML::XPath.first(doc, "//enclosure")

    doc.elements.each('rss/channel/title') do |e|
      self.title = e.text
    end
    doc.elements.each('rss/channel/link') do |e|
      self.site = e.text
    end
    doc.elements.each('rss/channel/itunes:image') do |e|
      self.logo_link = e.attributes['href']
    end
    doc.elements.each('rss/channel/itunes:summary') do |e|
      self.description = e.text
    end
    doc.elements.each('rss/channel/language') do |e|
      self.language = e.text
    end
    doc.elements.each('rss/channel/itunes:owner/itunes:email') do |e|
      self.email = e.text
    end
    doc.elements.each('rss/channel/itunes:owner/itunes:name') do |e|
      self.owner_name = e.text
    end

    if user
      self.user = user
      self.owner = user if self.email == user.email
    end

    self.save!
  rescue PodcastError => e
    self.feed_error = e.message
    raise PodcastError, self.feed_error
  end

  def check_for_feed_error
    self.feed_error = "I can't take feeds from that site! Try again." if Blacklist.find_by_domain($1)
    self.feed_error = "That's not a web address. Try again." unless feed_url =~ /^http:\/\/([^\/]+)\/(.*)/
    raise PodcastError, self.feed_error if self.feed_error
  end

  def average_time_between_episodes
    time_span = self.last_episode.published_at - self.first_episode.published_at
    time_span / self.episodes.count
  end

  def total_run_time
    self.episodes.sum(:duration) || 0
  end

  def clean_site
    self.site.to_url
  end

  def generate_url
    return true if pending?
    # Remove leading and trailing spaces
    self.clean_title = self.title.clone.strip
    # Remove all non-alphanumeric non-space characters
    self.clean_title.gsub!(/[^A-Za-z0-9\s]/, "")
    # Condense spaces and turn them into dashes
    self.clean_title.gsub!(/[\s]+/, '-')
    self.clean_title
  end

  def sanitize_title
    return true if pending?
    # Remove anything in parentheses
    self.title.gsub!(/[\s+]\(.*\)/, "")

    conflict = Podcast.find_by_clean_title(self.clean_title)
    self.clean_title += " 2" if conflict and conflict != self

    i = 2 # Number to attach to the end of the title to make it unique
    while(Podcast.find_by_clean_title(self.clean_title) and conflict != self)
      i += 1
      self.clean_title.chop!
      self.clean_title += i.to_s
    end

    self.title
  end

  def first_episode
    self.episodes.find(:first, :order => 'published_at ASC')
  end

  def last_episode
    self.episodes.find(:first, :order => 'published_at DESC')
  end

  def to_param
    clean_title
  end

  def download_logo
    return true if logo_link.nil? or logo_link.blank?

    @file = PaperClipFile.new
    @file.original_filename = File.basename(logo_link)
    open(logo_link) do |f|
      @file.to_tempfile = Tempfile.new('logo')
      @file.to_tempfile.write(f.read)
      @file.to_tempfile.rewind
      @file.content_type = f.content_type
      attachment_for(:logo).assign @file
    end
  end

  def retrieve_episodes_from_feed
    doc = REXML::Document.new(self.feed_content)
    doc.elements.each('rss/channel/item') do |e|
      begin
        episode = Episode.find_by_guid(e.elements['guid'].text)
        episode ||= Episode.new(:guid => e.elements['guid'].text)
      rescue
        episode = Episode.find_by_guid(e.elements['enclosure'].attributes['url'])
        episode ||= Episode.new(:guid => e.elements['enclosure'].attributes['url'])
      end

      episode.podcast_id = self.id
      episode.title = e.elements['title'].text rescue nil
      episode.summary = e.elements['description'] ? e.elements['description'].text : e.elements['itunes:summary'].text rescue nil
      episode.published_at = Time.parse(e.elements['pubDate'].text) rescue nil
      episode.enclosure_url = e.elements['enclosure'].attributes['url'] rescue nil
      episode.enclosure_type = e.elements['enclosure'].attributes['type'] rescue nil
      episode.enclosure_size = e.elements['enclosure'].attributes['length'] rescue nil

      begin
        # Time may be under an hour
        time = e.elements['itunes:duration'].text rescue "00:00"
        time = "00:#{time}" if time.size < 6
        time_multiplier = [24 * 60, 60, 1]
        episode.duration = time.split(":").map { |t| 
          seconds = t.to_i * time_multiplier[0]
          time_multiplier.shift
          seconds
        }.sum 
      rescue 
        episode.duration = 0
      end

      episode.save
    end
  rescue OpenURI::HTTPError
    puts "#{self.feed_url} not modified, skipping..."
  rescue StandardError => e
    self.feed_error = "Problem retrieving episodes from the feed"
    raise PodcastError, self.feed_error
  end

  def writable_by?(user)
    user and (self.user_id == user.id || self.owner_id == user.id || user.admin?)
  end

  def been_reviewed_by?(user)
    !!user && commenters.count(:conditions => {:id => user.id}) > 0
  end
end
