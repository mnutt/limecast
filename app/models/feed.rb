# == Schema Information
# Schema version: 20081010205531
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
#  state       :string(255)   
#

require 'open-uri'
require 'timeout'

class Feed < ActiveRecord::Base
  class BannedFeedException     < Exception; def message; "This feed site is not allowed." end end
  class InvalidAddressException < Exception; def message; "That's not a web address." end end
  class NoEnclosureException    < Exception; def message; "That's a text RSS feed, not an audio or video podcast." end end

  belongs_to :podcast

  before_create :sanitize
  before_save :remove_empty_podcast

  validates_presence_of :url
  validates_uniqueness_of :url

  acts_as_taggable

  named_scope :parsed,  :conditions => {:state => 'parsed'}
  def pending?; self.state == 'pending' || self.state.nil? end
  def parsed?;  self.state == 'parsed' end
  def failed?;  self.state == 'failed' end

  attr_accessor :content

  def async_create
    fetch
    parse
  rescue Exception
    self.update_attributes(:state => 'failed', :error => $!.class.to_s)
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
    update_podcast!
    update_episodes!
    self.update_attributes(:state => 'parsed')
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

    self.podcast.attachment_for(:logo).assign(file)
  end

  def update_episodes!
    RPodcast::Episode.parse(@content).each do |e|
      # XXX: Definitely need to figure out something better for this.
      episode = self.podcast.episodes.find_by_summary(e) || self.podcast.episodes.find_by_title(e) || self.podcast.episodes.new
      source = Source.find_by_guid_and_episode_id(e.guid, episode.id) || Source.new

      episode.update_attributes(
        :summary      => e.summary,
        :published_at => e.published_at,
        :title        => e.title,
        :duration     => e.duration
      )
      source.update_attributes(
        :guid       => e.guid,
        :type       => e.enclosure.type,
        :size       => e.enclosure.size,
        :url        => e.enclosure.url,
        :episode_id => episode.id
      )
    end
  end

  def update_podcast!
    parsed_feed = RPodcast::Feed.new(@content)

    self.podcast ||= Podcast.new
    self.download_logo(parsed_feed.image)
    self.podcast.update_attributes(
      :title       => parsed_feed.title,
      :description => parsed_feed.summary,
      :language    => parsed_feed.language,
      :owner_email => parsed_feed.owner_email,
      :owner_name  => parsed_feed.owner_name,
      :site        => parsed_feed.link
    )
  rescue Exception
    raise NoEnclosureException
  end

  protected

  def sanitize
    self.url.gsub!(%r{^feed://}, "http://")
  end

  def remove_empty_podcast
    self.podcast.destroy if self.failed? && !self.podcast.nil?
  end
end
