# == Schema Information
# Schema version: 20090303162109
#
# Table name: review_ratings
#
#  id         :integer(4)    not null, primary key
#  insightful :boolean(1)
#  review_id  :integer(4)
#  user_id    :integer(4)
#

class ReviewRating < ActiveRecord::Base
  belongs_to :review
  belongs_to :user

  named_scope :insightful,     :conditions => {:insightful => true}
  named_scope :not_insightful, :conditions => {:insightful => false}

  validates_uniqueness_of :review_id, :scope => :user_id

  def validate_on_create
    if self.review.reviewer == user
      errors.add(:user, 'cannot rate themselves.')
    end
  end
end

