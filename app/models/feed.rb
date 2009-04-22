# == Schema Information
# Schema version: 20090421203934
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
#  xml         :text(16777215 
#  ability     :integer(4)    default(0)
#  owner_id    :integer(4)    
#  owner_email :string(255)   
#  owner_name  :string(255)   
#  generator   :string(255)   
#  title       :string(255)   
#  description :string(255)   
#  language    :string(255)   
#

require 'open-uri'
require 'timeout'

class Feed < ActiveRecord::Base
  has_many :sources, :dependent => :destroy
  has_many :first_source, :class_name => 'Source', :limit => 1
  has_one  :newest_source, :class_name => 'Source', :include => :episode, :order => "episodes.published_at DESC"
  
  belongs_to :podcast
  belongs_to :owner, :class_name => 'User'
  belongs_to :finder, :class_name => 'User'

  before_destroy :destroy_podcast_if_last_feed
  after_destroy :add_podcast_message
  after_destroy :update_finder_score
  before_save :find_or_create_owner

  validates_presence_of   :url
  validates_uniqueness_of :url
  validates_length_of     :url, :maximum => 1024

  named_scope :from_limetracker, :conditions => ["feeds.generator LIKE ?", "%limecast.com/tracker%"]
  named_scope :with_itunes_link, :conditions => 'feeds.itunes_link IS NOT NULL and feeds.itunes_link <> ""'
  named_scope :parsed, :conditions => {:state => 'parsed'}
  named_scope :unclaimed, :conditions => "finder_id IS NULL"
  named_scope :claimed, :conditions => "finder_id IS NOT NULL"
  named_scope :found_by_admin, :include => :finder, :conditions => ["users.admin = ?", true]
  named_scope :found_by_nonadmin, :include => :finder, :conditions => ["users.admin = ? OR users.admin IS NULL", false]

  has_attached_file :logo,
                    :path => ":rails_root/public/feed_:attachment/:id/:style/:basename.:extension",
                    :url  => "/feed_:attachment/:id/:style/:basename.:extension",
                    :styles => { :square => ["85x85#", :png],
                                 :small  => ["170x170#", :png],
                                 :large  => ["300x300>", :png],
                                 :icon   => ["25x25#", :png],
                                 :thumb  => ["16x16#", :png] }

  attr_accessor :content

  define_index do
    indexes :url

    has :created_at, :podcast_id
  end

  def claim_by(user)
    update_attribute(:finder, user)
  end

  def diagnostic_xml
    doc = Hpricot.XML(self.xml)
    doc.search("item").remove
    PrettyPrinter.indent_xml(doc)
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

    self.attachment_for(:logo).assign(file)
  rescue OpenURI::HTTPError
  end

  def as(type)
    case type
    when :torrent
      self.remixed_as_torrent
    when :magnet
      self.remixed_as_magnet
    else
      self.xml
    end
  end

  def remix_feed
    xml = self.xml.to_s.dup

    h = Hpricot(self.xml)
    (h / 'item').each do |item|
      enclosure     = (item % 'enclosure') || {}
      media_content = (item % 'media:content') || {}

      urls = [enclosure['url'], media_content['url']].compact.uniq
      urls.each do |url|
        s = self.sources.find_by_url(url)

        unless s.nil?
          new_url = yield s
          xml.gsub!(url, new_url) unless new_url.nil?
        end
      end
    end

    xml
  end

  def remixed_as_torrent
    remix_feed do |s|
      s.torrent.url if s.torrent?
    end
  end

  def remixed_as_magnet
    remix_feed do |s|
      s.magnet_url
    end
  end

  def itunes_url
    "http://www.itunes.com/podcast?id=#{self.itunes_link}"
  end

  def miro_url
    "http://subscribe.getmiro.com/?url1=#{self.url}"
  end

  def update_finder_score
    self.finder.calculate_score! if self.finder
  end

  def writable_by?(user)
    !!(user && user.confirmed? && (self.finder_id == user.id || user.admin?))
  end

  def primary?
    self.podcast.primary_feed == self
  end

  def apparent_format
    self.sources.first.attributes['format'].to_s unless self.sources.blank?
  end

  def apparent_resolution
    self.sources.first.resolution unless self.sources.blank?
  end

  # takes the name of the Feed url (ie "http://me.com/feeds/quicktime-small" -> "Quicktime Small")
  def apparent_format_long
    url.split("/").last.titleize

    # Uncomment this to get the official format from the Source extension
    # ::FileExtensions::All[apparent_format.intern]
  end

  def formatted_bitrate
    self.bitrate.to_bitrate.to_s if self.bitrate and self.bitrate > 0
  end

  protected

  def destroy_podcast_if_last_feed
    self.podcast.destroy if self.podcast && self.podcast.feeds.size == 1
  end

  def add_podcast_message
    podcast.add_message "The #{apparent_format} feed has been removed." if podcast
  end

  def find_or_create_owner
    return true if (!self.owner_id.blank? || self.owner_email.blank?) && !self.owner_email_changed?

    self.owner = User.find_or_create_by_email(owner_email)

    return true
  end
end
