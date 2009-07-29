# == Schema Information
# Schema version: 20090728145034
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
  named_scope :unclaimed, :conditions => "user_id IS NULL"
  named_scope :claimed, :conditions => "user_id IS NOT NULL"

  validates_uniqueness_of :review_id, :scope => :user_id, :unless => Proc.new { |rating| rating.user.nil? }

  def validate_on_create
    if self.review.reviewer == user
      errors.add(:user, 'cannot rate themselves.')
    end
  end

  def claim_by(user)
    self.user = user
    save
  end
end

