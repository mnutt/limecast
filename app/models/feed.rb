# == Schema Information
# Schema version: 20081027172537
#
# Table name: feeds
#
#  id          :integer(4)    not null, primary key
#  url         :string(255)   
#  error       :string(255)   
#  itunes_link :string(255)   
#  podcast_id  :integer(4)    
#  created_at  :datetime      
#  updated_at  :datetime      
#  state       :string(255)   default("pending")
#  bitrate     :integer(4)    
#  finder_id   :integer(4)    
#  format      :string(255)   
#

require 'open-uri'
require 'timeout'

class Feed < ActiveRecord::Base
  class BannedFeedException     < Exception; def message; "This feed site is not allowed." end end
  class InvalidAddressException < Exception; def message; "That's not a web address." end end
  class NoEnclosureException    < Exception; def message; "That's a text RSS feed, not an audio or video podcast." end end
  class DuplicateFeedExeption   < Exception; def message; "This feed has already been added to the system." end end
  class FeedDoesNotMatchPodcast < Exception; def message; "This feed does not match the podcast that it is associated with." end end

  has_many :sources, :dependent => :destroy
  belongs_to :podcast
  belongs_to :finder, :class_name => 'User'

  before_create :sanitize
  before_save :remove_empty_podcast
  after_create  { |f| f.finder.calculate_score! if f.finder }
  after_destroy { |f| f.finder.calculate_score! if f.finder }

  validates_presence_of   :url
  validates_uniqueness_of :url

  named_scope :parsed, :conditions => {:state => 'parsed'}
  def pending?; self.state == 'pending' || self.state.nil? end
  def parsed?;  self.state == 'parsed' end
  def failed?;  self.state == 'failed' end

  attr_accessor :content

  def refresh
    fetch
    parse
    update_from_feed
  rescue Exception
    self.update_attributes(:state => 'failed', :error => $!.class.to_s)
  end

  def url
    url = self.read_attribute(:url)

    # Add http:// if the url does not have :// in it.
    url = 'http://' + url unless url =~ %r{://}

    url
  end

  def fetch
    raise InvalidAddressException unless self.url =~ %r{^([^/]*//)?([^/]+)}
    raise BannedFeedException if Blacklist.find_by_domain($2)

    Timeout::timeout(5) do
      OpenURI::open_uri(self.url) do |f|
        @content = f.read
      end
    end
  rescue NoMethodError
    raise InvalidAddressException
  end

  def parse
    begin
      @feed = RPodcast::Feed.new(@content)
    rescue RPodcast::NoEnclosureError
      raise NoEnclosureException
    end
  end

  def update_from_feed
    update_podcast!
    update_badges!
    update_episodes!

    self.update_attributes(:bitrate => @feed.bitrate.nearest_multiple_of(64), :state => 'parsed')
  end

  def update_episodes!
    @feed.episodes.each do |e|
      # XXX: Definitely need to figure out something better for this.
      episode = self.podcast.episodes.find_by_summary(e.summary) || self.podcast.episodes.find_by_title(e.title) || self.podcast.episodes.new
      source = Source.find_by_guid_and_episode_id(e.guid, episode.id) || Source.new(:feed => self)

      # The feed is a duplicate if the source found matches a source from another feed.
      raise DuplicateFeedExeption if source.feed != self

      episode.update_attributes(
        :summary      => e.summary,
        :published_at => e.published_at,
        :title        => e.title,
        :duration     => e.duration
      )
      source.update_attributes(
        :guid       => e.guid,
        :format     => e.enclosure.format.to_s,
        :type       => e.enclosure.content_type,
        :size       => e.enclosure.size,
        :url        => e.enclosure.url,
        :episode_id => episode.id
      )
    end
  end

  def update_podcast!
    self.podcast ||= Podcast.find_by_site(@feed.link) || Podcast.new
    raise FeedDoesNotMatchPodcast unless self.similar_to_podcast?(self.podcast)

    self.podcast.download_logo(@feed.image) unless @feed.image.nil?
    self.podcast.update_attributes!(
      :title       => @feed.title,
      :description => @feed.summary,
      :language    => @feed.language,
      :owner_email => @feed.owner_email,
      :owner_name  => @feed.owner_name,
      :site        => @feed.link
    )
  rescue RPodcast::NoEnclosureError
    raise NoEnclosureException
  end

  def update_badges!
    self.podcast.tag_string = "hd" if @feed.hd?
    self.podcast.tag_string = "creativecommons" if @feed.creative_commons?
    self.podcast.tag_string = "video" if @feed.video?
    self.podcast.tag_string = "audio" if @feed.audio?
    self.podcast.tag_string = "explicit" if @feed.explicit?
    self.podcast.tag_string = "torrent" if @feed.torrent?
  end

  def writable_by?(user)
    !!(user && user.active? && (self.finder_id == user.id || user.admin?))
  end

  def primary?
    self.podcast.feeds.first == self
  end

  def similar_to_podcast?(podcast)
    parse # rescue return false
    return true if podcast.new_record?
    return false unless URI::parse(@feed.link).host == URI::parse(podcast.site).host
    true
  end

  def apparent_format
    self.sources.first.attributes['format'].to_s unless self.sources.blank?
  end

  def formatted_bitrate
    self.bitrate.to_bitrate.to_s if self.bitrate and self.bitrate > 0
  end

  def rfeed
    @feed
  end

  def just_created?
    self.created_at > 2.minutes.ago
  end

  protected

  def sanitize
    self.url.gsub!(%r{^feed://}, "http://")
  end

  def remove_empty_podcast
    self.podcast.destroy if self.failed? && !self.podcast.nil?
  end
end
