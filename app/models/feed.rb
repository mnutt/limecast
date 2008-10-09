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

require 'open-uri'
require 'timeout'
require 'rexml/document'
require 'paperclip_file'

class Feed < ActiveRecord::Base
  class BannedFeedException     < Exception; def message; "This feed site is not allowed." end end
  class InvalidAddressException < Exception; def message; "That's not a web address." end end

  belongs_to :podcast

  before_create :sanitize

  validates_presence_of :url
  validates_uniqueness_of :url

  acts_as_taggable

  named_scope :parsed,  :conditions => {:state => 'parsed'}
  def pending?; self.state == 'pending' || self.state.nil? end
  def parsed?;  self.state == 'parsed' end
  def fetched?; self.state == 'fetched' end
  def failed?;  self.state == 'failed' end

  def async_create
    raise InvalidAddressException unless self.url =~ %r{^([^/]*//)?([^/]+)}
    raise BannedFeedException if Blacklist.find_by_domain($2)

    fetch
    parse
  rescue Exception
    self.update_attributes(:state => 'failed', :error => $!.class.to_s)
  end

  def fetch
    Timeout::timeout(5) do
      OpenURI::open_uri(self.url) do |f|
        self.content = f.read
      end
    end
    self.update_attributes(:state => 'fetched')
  rescue NoMethodError
    raise InvalidAddressException
  end

  def parse
    update_podcast_info!
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
      end
    end

    self.podcast.attachment_for(:logo).assign(file)
  end

  def update_episodes!
    RPodcast::Episode.parse(content).each do |e|
      # XXX: Definitely need to figure out something better for this.
      episode = self.podcast.episodes.find_by_guid(e.guid) || self.podcast.episodes.find_by_summary(e) || self.podcast.episodes.find_by_title(e) || self.podcast.episodes.new
      episode.update_attributes(
        :summary        => e.summary,
        :guid           => e.guid,
        :published_at   => e.published_at,
        :title          => e.title,
        :enclosure_type => e.enclosure.type,
        :enclosure_size => e.enclosure.size,
        :enclosure_url  => e.enclosure.url,
        :duration       => e.duration
      )
    end
  end

  def update_podcast_info!
    parsed_feed = RPodcast::Feed.new(content)

    attrs = {
      :title       => parsed_feed.title,
      :description => parsed_feed.summary,
      :language    => parsed_feed.language,
      :owner_email => parsed_feed.owner_email,
      :owner_name  => parsed_feed.owner_name,
      :site        => parsed_feed.link
    }

    if self.podcast.nil?
      self.podcast = Podcast.new(attrs)
    else
      self.podcast.update_attributes(attrs)
    end

    self.download_logo(parsed_feed.image)
  end
  
  protected

  def sanitize
    self.url.gsub!(%r{^feed://}, "http://")
  end
end
