# == Schema Information
# Schema version: 20100504173954
#
# Table name: queued_podcasts
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

class QueuedPodcast < ActiveRecord::Base
  belongs_to :user
  belongs_to :podcast

  validates_presence_of   :url
  validates_uniqueness_of :url
  validates_length_of     :url, :maximum => 1024

  named_scope :unclaimed, :conditions => {:user_id => nil}#"user_id IS NULL"
  named_scope :claimed, :conditions => "user_id IS NOT NULL"
  named_scope :parsed, :conditions => {:state => 'parsed'}
  named_scope :by_url, lambda { |url|
    {:conditions => { :url => QueuedPodcast.clean_url(url) }}
  }
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
  
  # Ensures that all QueuedPodcasts either are attached to a Podcast
  # or are destroyed.
  def self.synchronize_all
    # find or create the podcast if it isn't linked
    self.find_each do |qp|
      if qp.podcast.nil?
        qp.podcast = Podcast.find_by_url(qp.url)
        qp.podcast.nil? ? qp.destroy : qp.save
      end
    end

    # create a QueuedPodcast for Podcasts without one
    Podcast.find_each do |p|
      if p.queued_podcast.nil?
        QueuedPodcast.create(:podcast_id => p.id, :url => p.url, :user_id => p.finder_id, :state => (p.state || 'parsed'))
      end
    end
  end

  def url=(val)
    val = QueuedPodcast.clean_url(val)
    write_attribute(:url, val)
  end

  def self.find_or_initialize_by_url(url)
    self.by_url(url).first || self.new(:url => url)
  end

  def self.find_or_create_by_url(url)
    self.by_url(url).first || self.create(:url => url)
  end
end
