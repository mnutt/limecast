module CommentsHelper
  def can_add_comments?(episode)
    if current_user.nil?
      episode.open_for_comments?
    else
      !episode.been_reviewed_by?(current_user) && episode.open_for_comments?
    end
  end

  def can_edit_comment?(comment)
    comment.editable? && comment.commenter == current_user
  end

  def comment_rating(comment)
    if comment.positive
      image_tag('icons/thumbs_up.png', :alt => 'Thumbs Up', :class => 'rating')
    else
      image_tag('icons/thumbs_down.png', :alt => 'Thumbs Down', :class => 'rating')
    end
  end
end
