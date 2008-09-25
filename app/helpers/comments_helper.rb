module CommentsHelper
  def can_add_comments?(episode)
    !episode.been_reviewed_by?(current_user) && episode.open_for_comments?
  end

  def can_edit_comment?(comment)
    comment.editable? && comment.commenter == current_user
  end
end
