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

