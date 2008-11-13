module ReviewsHelper
  def can_add_reviews?(episode)
    if current_user.nil?
      episode.open_for_reviews?
    else
      !episode.been_reviewed_by?(current_user) && episode.open_for_reviews?
    end
  end

  def can_edit_review?(review)
    review.editable? && review.reviewer == current_user
  end

  def review_rating(review)
    if review.positive
      image_tag('icons/thumbs_up.png', :alt => 'Thumbs Up', :class => 'rating')
    else
      image_tag('icons/thumbs_down.png', :alt => 'Thumbs Down', :class => 'rating')
    end
  end
end
