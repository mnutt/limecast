# == Schema Information
# Schema version: 20081010205531
#
# Table name: podcasts
#
#  id                :integer(4)    not null, primary key
#  title             :string(255)   
#  site              :string(255)   
#  logo_file_name    :string(255)   
#  logo_content_type :string(255)   
#  logo_file_size    :string(255)   
#  created_at        :datetime      
#  updated_at        :datetime      
#  user_id           :integer(4)    
#  description       :text          
#  language          :string(255)   
#  category_id       :integer(4)    
#  clean_url         :string(255)   
#  owner_id          :integer(4)    
#  owner_email       :string(255)   
#  owner_name        :string(255)   
#  custom_title      :string(255)   
#

require 'paperclip_file'

class Podcast < ActiveRecord::Base
  belongs_to :user
  belongs_to :owner, :class_name => 'User'
  belongs_to :category
  has_many :feeds
  has_many :episodes, :dependent => :destroy

  has_attached_file :logo,
                    :styles => { :square => ["85x85#", :png],
                                 :small  => ["170x170#", :png],
                                 :large  => ["600x600>", :png],
                                 :icon   => ["16x16#", :png] }

  named_scope :older_than, lambda {|date| {:conditions => ["podcasts.created_at < (?)", date]} }
  named_scope :parsed, lambda {
    { :conditions => {:id => Feed.parsed.map(&:podcast_id).uniq } }
  }

  attr_accessor :has_episodes

  acts_as_taggable

  before_save  :attempt_to_find_owner
  before_save  :cache_custom_title
  before_save  :sanitize_title
  before_save  :sanitize_url
  after_create :distribute_point, :if => '!user.nil?'

  # Search
  define_index do
    indexes :title, :site, :description
    indexes user.login, :as => :user
    indexes owner.login, :as => :owner
    indexes episodes.title, :as => :episode_title
    indexes episodes.summary, :as => :episode_summary

    has :created_at
  end


  def average_time_between_episodes
    return 0 if self.episodes.count < 2
    time_span = self.episodes.newest.first.published_at - self.episodes.oldest.first.published_at
    time_span / (self.episodes.count - 1)
  end

  def clean_site
    self.site.to_url
  end

  def comments
    Comment.for_podcast(self)
  end

  def just_created?
    self.created_at > 2.minutes.ago
  end

  def total_run_time
    self.episodes.sum(:duration) || 0
  end

  def to_param
    clean_url
  end

  def writable_by?(user)
    # TODO: refactor
    !!(user and user.active? and ((self.user_id == user.id && !self.owner_id) || self.owner_id == user.id || user.admin?))
  end

  protected

  def sanitize_title
    return if self.title.nil?

    # Remove anything in parentheses
    self.title.gsub!(/[\s+]\(.*\)/, "")

    conflict = Podcast.find_by_title(self.title)
    self.title = "#{self.title} 2" if conflict and conflict != self

    i = 2 # Number to attach to the end of the title to make it unique
    while(Podcast.find_by_title(self.title) and conflict != self)
      i += 1
      self.title.chop!
      self.title = "#{self.title}#{i.to_s}"
    end

    self.title
  end

  def sanitize_url
    return if self.title.nil?

    # Remove leading and trailing spaces
    self.clean_url = self.title.clone.strip

    # Remove all non-alphanumeric non-space characters
    self.clean_url.gsub!(/[^A-Za-z0-9\s]/, "")

    # Condense spaces and turn them into dashes
    self.clean_url.gsub!(/[\s]+/, '-')
    self.clean_url
  end

  def distribute_point
    self.user.score += 1
    self.user.save
  end

  def cache_custom_title
    self.custom_title = custom_title.blank? ? title : custom_title
  end

  def attempt_to_find_owner
    self.owner ||= User.find_by_email(self.owner_email)
    true
  end
end
