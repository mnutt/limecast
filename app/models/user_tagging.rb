# == Schema Information
# Schema version: 20090306193031
#
# Table name: user_taggings
#
#  id         :integer(4)    not null, primary key
#  user_id    :integer(4)
#  tagging_id :integer(4)
#

# This is merely a denormalized table to track which users added taggings.
class UserTagging < ActiveRecord::Base
  belongs_to :user
  belongs_to :tagging

  named_scope :for_podcast, lambda { |p| {:include => :tagging, :conditions => ["taggings.podcast_id = ?", p]} }

  validates_uniqueness_of :tagging_id, :scope => :user_id
  validate :allowable_user_taggings

  def podcast
    tagging.podcast
  end

  def tag
    tagging.tag
  end

  def writable_by?(u)
    user == u || tagging.podcast.editors.include?(u)
  end

  def allowable_user_taggings
    if !tagging.podcast.editors.include?(user) && user.taggings.for_podcast(podcast).count >= 8
      errors.add(:user, "is only allowed to make 8 tags for this podcast")
    end
  end
end
