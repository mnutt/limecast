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
  class DuplicateFeedExeption   < Exception; def message; "This feed has already been added to the system." end end

  has_many :sources
  belongs_to :podcast
  belongs_to :finder, :class_name => 'User'

  before_create :sanitize
  before_save :remove_empty_podcast
  after_create :distribute_point, :if => '!finder.nil?'

  validates_presence_of   :url
  validates_uniqueness_of :url

  named_scope :parsed, :conditions => {:state => 'parsed'}
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
    begin
      @feed = RPodcast::Feed.new(@content)
    rescue RPodcast::NoEnclosureError
      raise NoEnclosureException
    end

    update_podcast!
    update_episodes!

    self.update_attributes(:bitrate => @feed.bitrate.nearest_multiple_of(64), :state => 'parsed')
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
        :type       => e.enclosure.type,
        :size       => e.enclosure.size,
        :url        => e.enclosure.url,
        :episode_id => episode.id
      )
    end
  end

  def update_podcast!
    self.podcast = Podcast.find_by_site(@feed.link) || Podcast.new
    self.download_logo(@feed.image)
    self.podcast.update_attributes!(
      :title       => @feed.title,
      :description => @feed.summary,
      :language    => @feed.language,
      :owner_email => @feed.owner_email,
      :owner_name  => @feed.owner_name,
      :site        => @feed.link
    )
    p = self.podcast
    p.save!
  #rescue Exception
  #  raise NoEnclosureException
  end

  def writable_by?(user)
    !!(user && user.active? && (self.finder_id == user.id || user.admin?))
  end

  def rfeed
    @feed
  end

  protected

  def sanitize
    self.url.gsub!(%r{^feed://}, "http://")
  end

  def remove_empty_podcast
    self.podcast.destroy if self.failed? && !self.podcast.nil?
  end

  def distribute_point
    self.finder.score += 1
    self.finder.save
  end
end
