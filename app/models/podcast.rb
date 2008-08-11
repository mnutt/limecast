# == Schema Information
# Schema version: 20080803203636
#
# Table name: podcasts
#
#  id                :integer(4)    not null, primary key
#  title             :string(255)
#  site              :string(255)
#  feed              :string(255)
#  logo_file_name    :string(255)
#  logo_content_type :string(255)
#  logo_file_size    :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  feed_etag         :string(255)
#  user_id           :integer(4)
#  description       :text
#  language          :string(255)
#  category_id       :integer(4)
#  clean_title       :string(255)
#  itunes_link       :string(255)
#  owner_id          :integer(4)
#  email             :string(255)
#  owner_name        :string(255)
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
  has_many :comments, :as => :commentable, :conditions => "user_id IS NOT NULL", :dependent => :destroy
  has_many :episodes, :order => "published_at DESC", :dependent => :destroy

  attr_accessor :logo_link, :has_episodes, :feed_error

  validates_presence_of :title
  validates_uniqueness_of :feed

  acts_as_taggable

  has_attached_file :logo,
                    :styles => { :square => ["85x85#", :png],
                                 :small  => ["170x170#", :png],
                                 :icon   => ["16x16#", :png] }

  before_create :sanitize_title
  before_create :generate_url
  after_create :retrieve_episodes_from_feed
  before_save :download_logo
  before_create :check_for_feed_error

  define_index do
    indexes :title, :site, :description
    indexes user.login, :as => :user
    indexes owner.login, :as => :owner
    indexes episodes.title, :as => :episode_title
    indexes episodes.summary, :as => :episode_summary
    indexes comments.title, :as => :comment_title
    indexes comments.body, :as => :comment_body

    has :created_at
  end

  def self.retrieve_feed(url)

    Timeout::timeout(5) do
      OpenURI::open_uri(url) do |f|
        f.read
      end
    end
  rescue Timeout::Error
    raise PodcastError, "Not found. Try again."
  rescue Errno::ENETUNREACH
    raise PodcastError, "Not found. Try again."
  rescue StandardError => e
    raise PodcastError, "Weird server error. Try again."
  end

  def self.new_from_feed(url)
    podcast = self.new
    podcast.feed = url

    begin
      is_site = (url =~ /^http:\/\/([^\/]+)\/(.*)/)
      raise PodcastError, "That feed has already been added to the system. Try again" if Podcast.find_by_feed(url)
      raise PodcastError, "I can't take feeds from that site! Try again." if Blacklist.find_by_domain($1)
      raise PodcastError, "That's not a web address. Try again." unless is_site
      feed = retrieve_feed(url)

      doc = REXML::Document.new(feed)
      raise PodcastError, "This is not a podcast feed. Try again." unless REXML::XPath.first(doc, "//enclosure")

      doc.elements.each('rss/channel/title') do |e|
        podcast.title = e.text
      end
      doc.elements.each('rss/channel/link') do |e|
        podcast.site = e.text
      end
      doc.elements.each('rss/channel/itunes:image') do |e|
        podcast.logo_link = e.attributes['href']
      end
      doc.elements.each('rss/channel/itunes:summary') do |e|
        podcast.description = e.text
      end
      doc.elements.each('rss/channel/language') do |e|
        podcast.language = e.text
      end
      doc.elements.each('rss/channel/itunes:owner/itunes:email') do |e|
        podcast.email = e.text
      end
      doc.elements.each('rss/channel/itunes:owner/itunes:name') do |e|
        podcast.owner_name = e.text
      end
    rescue PodcastError => e
      podcast.feed_error = e.message
    end

    podcast
  end

  def check_for_feed_error
    self.feed_error.nil?
  end

  def average_time_between_episodes
    time_span = self.last_episode.published_at - self.first_episode.published_at
    time_span / self.episodes.count
  end

  def total_run_time
    self.episodes.sum(:duration)
  end

  def generate_url
    self.clean_title = self.title
    # Remove all non-alphanumeric non-space characters
    self.clean_title.gsub!(/[^A-Za-z0-9\s]/, "")
    # Condense spaces and turn them into dashes
    self.clean_title.gsub!(/[\s]+/, '-')
  end

  def sanitize_title
    # Remove anything in parentheses
    self.title.gsub!(/[\s+]\(.*\)/, "")

    self.title
  end

  def sanitize_description
    sentences = self.description.split('.')
    sentences.select { |sentence| commas = 0
                                  sentence.split('').each {|char| commas += 1 if char == ','}
                                  commas < 5 }.join(".")
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
    @feed = Podcast.retrieve_feed(feed)

    @feed_episodes = []

    doc = REXML::Document.new(@feed)
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

      # Time may be under an hour
      time = e.elements['itunes:duration'].text rescue "00:00"
      time = "00:#{time}" if time.size < 6
      episode.duration = Time.parse(time) - Time.now.beginning_of_day rescue nil

      episode.save

      @feed_episodes << episode
    end

    @feed_episodes
  rescue OpenURI::HTTPError
    puts "#{self.feed} not modified, skipping..."
  rescue StandardError => e
    puts "Problem with feed #{self.feed}: #{e.message}"
  end

  def writable_by?(user)
    user and self.user_id == user.id || self.owner_id == user.id
  end
end
