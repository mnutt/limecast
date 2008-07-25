# == Schema Information
# Schema version: 20080701214920
#
# Table name: podcasts
#
#  id                :integer       not null, primary key
#  title             :string(255)   
#  site              :string(255)   
#  feed              :string(255)   
#  logo_file_name    :string(255)   
#  logo_content_type :string(255)   
#  logo_file_size    :string(255)   
#  created_at        :datetime      
#  updated_at        :datetime      
#  feed_etag         :string(255)   
#  description       :text          
#  language          :string(255)   
#  category_id       :integer       
#  user_id           :integer(11)   
#

require 'open-uri'
require 'rexml/document'
require 'paperclip_file'

class Podcast < ActiveRecord::Base
  belongs_to :user
  belongs_to :owner, :class_name => 'User'
  belongs_to :category
  has_many :comments, :as => :commentable, :dependent => :destroy
  has_many :episodes, :dependent => :destroy

  attr_accessor :logo_link

  acts_as_taggable

  has_attached_file :logo,
                    :styles => { :square => ["85x85#", :png],
                                 :small  => ["170x170#", :png],
                                 :icon   => ["16x16#", :png] }

  before_create :generate_clean_title
  after_create :retrieve_episodes_from_feed
  before_save :download_logo

  def self.new_from_feed(feed)
    podcast = self.new
    podcast.feed = feed

    OpenURI.open_uri(feed) do |f|
      @feed = f.read
    end

    doc = REXML::Document.new(@feed)
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

    podcast
  end

  def average_time_between_episodes
    time_span = self.last_episode.published_at - self.first_episode.published_at
    time_span / self.episodes.count
  end

  def total_run_time
    self.episodes.sum(:duration)
  end

  def generate_clean_title
    self.clean_title = self.title.gsub(/[^A-Za-z0-9]/, "-")
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
    # OpenURI.open_uri(feed, "If-None-Match" => (self.feed_etag || "")) do |f|
    OpenURI.open_uri(feed) do |f|
      @etag = f.meta['etag']
      @feed = f.read
    end

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

      # Time may be under an hour
      time = e.elements['itunes:duration'].text rescue "00:00"
      time = "00:#{time}" if time.size < 6
      episode.duration = Time.parse(time) - Time.now.beginning_of_day rescue nil

      episode.save

      @feed_episodes << episode
    end

    self.feed_etag = @etag
    @feed_episodes
  rescue OpenURI::HTTPError
    puts "#{self.feed} not modified, skipping..."
  rescue
    puts "Problem with feed #{self.feed}"
  end

  def writable_by?(user)
    user and self.user_id == user.id
  end
end
