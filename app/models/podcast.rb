require 'open-uri'
require 'rexml/document'
require 'paperclip_file'

class Podcast < ActiveRecord::Base
  belongs_to :user
  has_many :comments, :as => :commentable, :dependent => :destroy
  has_many :episodes, :dependent => :destroy

  attr_accessor :logo_link

  acts_as_taggable

  has_attached_file :logo,
                    :styles => { :square => ["64x64#", :png],
                                 :small  => ["150x150#", :png] }

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

    podcast
  end

  def download_logo
    return if logo_link.nil?

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
      episode.duration = Time.parse(e.elements['itunes:duration'].text) - Time.now.beginning_of_day rescue nil
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
    user and self.user == user
  end
end
