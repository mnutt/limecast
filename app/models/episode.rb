# == Schema Information
# Schema version: 20081027172537
#
# Table name: episodes
#
#  id                     :integer(4)    not null, primary key
#  podcast_id             :integer(4)
#  summary                :text
#  published_at           :datetime
#  created_at             :datetime
#  updated_at             :datetime
#  thumbnail_file_size    :integer(4)
#  thumbnail_file_name    :string(255)
#  thumbnail_content_type :string(255)
#  duration               :integer(4)
#  title                  :string(255)
#  clean_url              :string(255)
#

class Episode < ActiveRecord::Base
  belongs_to :podcast

  has_attached_file :thumbnail, :whiny_thumbnails => true,
                    :styles => { :square => ["85x85#", :png],
                                 :small  => ["170x170#", :png] }
  has_many :reviews, :dependent => :destroy
  has_many :reviewers, :through => :reviews
  has_many :sources, :dependent => :destroy, :include => [:feed]

  validates_presence_of :podcast_id, :published_at

  before_create :generate_url

  named_scope :with_same_title_as, lambda {|who| {:conditions => {:podcast_id => who.podcast.id, :clean_url => who.clean_url}} }
  named_scope :without, lambda {|who| who.id.nil? ? {} : {:conditions => ["episodes.id NOT IN (?)", who.id]} }
  named_scope :newest, lambda {|*count| {:limit => (count[0] || 1), :order => "published_at DESC"} }
  named_scope :oldest, lambda {|*count| {:limit => (count[0] || 1), :order => "published_at ASC"} }

  define_index do
    indexes :title, :summary

    has :created_at
  end

  def generate_url
    base_title = self.published_at.to_date.to_s(:url)

    iterate(1) do |i|
      self.clean_url = base_title.dup
      self.clean_url << "-#{i}" unless i == 1

      Episode.with_same_title_as(self).without(self).count > 0
    end

    self.clean_url
  end

  def date_title
    self.published_at.to_date
  end

  def audio_source
    self.sources.select{|s| s.format == "mp3"}.first
  end

  def to_param
    clean_url
  end

  def writable_by?(user)
    self.podcast.writable_by?(user)
  end

  def been_reviewed_by?(user)
    reviewers.reload
    !!user && reviewers.count(:conditions => {:id => user.id}) > 0
  end

  def open_for_reviews?
    self.podcast.episodes.newest.first.id == self.id
  end
end
