# == Schema Information
# Schema version: 20090306193031
#
# Table name: reviews
#
#  id             :integer(4)    not null, primary key
#  user_id        :integer(4)
#  body           :text
#  created_at     :datetime
#  updated_at     :datetime
#  title          :string(255)
#  positive       :boolean(1)
#  episode_id     :integer(4)
#  insightful     :integer(4)    default(0)
#  not_insightful :integer(4)    default(0)
#

class Review < ActiveRecord::Base
  belongs_to :episode
  belongs_to :reviewer, :class_name => 'User', :foreign_key => 'user_id'

  has_many :review_ratings, :dependent => :destroy

  after_create  { |c| c.reviewer.calculate_score! if c.reviewer }
  after_destroy { |c| c.reviewer.calculate_score! if c.reviewer }

  validates_presence_of :episode_id, :body

  named_scope :newer_than, lambda {|who| {:conditions => ["reviews.created_at >= (?)", who.created_at]} }
  named_scope :without, lambda {|who| {:conditions => ["reviews.id NOT IN (?)", who.id]} }
  named_scope :for_podcast, lambda {|podcast| {:conditions => {:episode_id => podcast.episodes.map(&:id)}} }
  named_scope :that_are_positive, :conditions => {:positive => true}
  named_scope :that_are_negative, :conditions => {:positive => false}
  named_scope :newest, lambda {|*count| {:limit => (count[0] || 1), :order => "created_at DESC"} }
  named_scope :with_episode, :conditions => "reviews.episode_id IS NOT null"
  named_scope :unclaimed, :conditions => "user_id IS NULL"
  named_scope :claimed, :conditions => "user_id IS NOT NULL"

  define_index do
    indexes :title, :body

    has episode.podcast(:id), :as => :podcast_id
    has :created_at
  end

  def writable_by?(user)
    return false unless user
    return true if user.admin?

    user == self.reviewer && self.editable?
  end

  def rated_by?(user)
    user && self.review_ratings.exists?(:user_id => user.id)
  end

  def editable?
    self.episode.open_for_reviews? && self.review_ratings.count == 0
  end

  def insightful
    self.review_ratings.insightful.count
  end

  def not_insightful
    self.review_ratings.not_insightful.count
  end
end
