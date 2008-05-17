require 'open-uri'
require 'rexml/document'
require 'paperclip_file'

class Podcast < ActiveRecord::Base
  belongs_to :user
  has_many :episodes

  attr_accessor :logo_link

  has_attached_file :logo,
                    :styles => { :square => ["64x64#", :png],
                                 :small  => "150x150>" }

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

    podcast
  end

  before_save :download_logo

  def retrieve_episodes_from_feed
    OpenURI.open_uri(feed, "If-None-Match" => (self.feed_etag || "")) do |f|
      self.update_attribute(:feed_etag, f.meta['etag'])
      @feed = f.read
    end

    @feed_episodes = []

    doc = REXML::Document.new(@feed)
    doc.elements.each('rss/channel/item') do |e|
      episode = self.episodes.find_or_create_by_guid(e.elements['guid'].text)
      episode.title = e.elements['title'].text rescue nil
      episode.summary = e.elements['itunes:summary'] ? e.elements['itunes:summary'].text : e.elements['description'].text rescue nil
      episode.published_at = Time.parse(e.elements['pubDate'].text) rescue nil
      episode.enclosure_url = e.elements['enclosure'].attributes['url'] rescue nil
      episode.enclosure_type = e.elements['enclosure'].attributes['type'] rescue nil
      episode.duration = Time.parse(e.elements['itunes:duration'].text) - Time.now.beginning_of_day rescue nil
      episode.save
      @feed_episodes << episode
    end

    @feed_episodes
  rescue
    puts "Problem with feed #{self.feed}"
  end

  def download_logo
    return if logo_link.nil?

    @file = PaperClipFile.new
    @file.original_filename = File.basename(logo_link)
    open(feed) do |f|
      @file.to_tempfile = StringIO.new(f.read)
      @file.content_type = f.content_type
      @file.size = f.size
      self.logo.assign @file
    end
  end
end
