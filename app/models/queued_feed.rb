# == Schema Information
# Schema version: 20090611152951
#
# Table name: queued_feeds
#
#  id         :integer(4)    not null, primary key
#  url        :string(255)   
#  error      :string(255)   
#  state      :string(255)   
#  user_id    :integer(4)    
#  created_at :datetime      
#  updated_at :datetime      
#  podcast_id :integer(4)    
#

require 'open-uri'
require 'timeout'

# XXX: Rename to FeedUrl
class QueuedFeed < ActiveRecord::Base
  belongs_to :user
  belongs_to :podcast

  validates_presence_of   :url
  validates_uniqueness_of :url
  validates_length_of     :url, :maximum => 1024

  named_scope :unclaimed, :conditions => {:user_id => nil}#"user_id IS NULL"
  named_scope :claimed, :conditions => "user_id IS NOT NULL"
  named_scope :parsed, :conditions => {:state => 'parsed'}
  def pending?;         self.state == 'pending' || self.state.nil? end
  def parsed?;          self.state == 'parsed' end
  def failed?;          self.state == 'failed' end
  def blacklisted?;     self.state == 'blacklisted' end
  def duplicate?;       self.state == 'duplicate' end
  def invalid_xml?;     self.state == 'invalid_xml' end
  def invalid_address?; self.state == 'invalid_address' end
  def no_enclosure?;    self.state == 'no_enclosure' end

  attr_accessor :content

  def claim_by(user)
    self.update_attributes(:user => user)
    self.podcast.update_attributes(:finder => user) if self.podcast
  end

  def self.clean_url(url)
    url ||= ""
    url.gsub!(%r{^feed://}, "http://")
    url.strip!
    url = 'http://' + url.to_s unless url.to_s =~ %r{://}
    url
  end

  def url=(val)
    val = QueuedFeed.clean_url(val)
    write_attribute(:url, val)
  end

  def self.find_or_initialize_by_url(url)
    self.find_by_url(self.clean_url(url)) || self.new(:url => url)
  end

  def self.find_or_create_by_url(url)
    self.find_by_url(self.clean_url(url)) || self.create(:url => url)
  end

  def self.find_by_url(url)
    super(self.clean_url(url))
  end
end
