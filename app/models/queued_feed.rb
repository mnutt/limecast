# == Schema Information
# Schema version: 20090306193031
#
# Table name: feeds
#
#  id          :integer(4)    not null, primary key
#  url         :string(255)
#  error       :string(255)
#  state       :string(255)   default("pending")
#  feed_id     :integer(4)
#  created_at  :datetime
#  updated_at  :datetime
#

require 'open-uri'
require 'timeout'

# XXX: Rename to URL
class QueuedFeed < ActiveRecord::Base
  belongs_to :feed
  belongs_to :user

  #after_create :process

  validates_presence_of   :url
  validates_uniqueness_of :url
  validates_length_of     :url, :maximum => 1024

  named_scope :parsed, :conditions => {:state => 'parsed'}
  def pending?;     self.state == 'pending' || self.state.nil? end
  def parsed?;      self.state == 'parsed' end
  def failed?;      self.state == 'failed' end
  def blacklisted?; self.state == 'blacklisted' end

  attr_accessor :content

  define_index do
    indexes :url

    has :created_at
  end

  def self.clean_url(url)
    url.gsub!(%r{^feed://}, "http://")
    url.strip!
    url = 'http://' + url.to_s unless url.to_s =~ %r{://}
    url
  end

  def self.add_to_queue(url)
    url = self.clean_url(url)

    QueuedFeed.find_by_url(url) || QueuedFeed.create(:url => url)
  end

  protected

  def process
    FeedProcessor.send_later :process, self
  end
end
