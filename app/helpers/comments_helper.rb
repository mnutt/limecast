module CommentsHelper
  def show_add_form?(commentable)
    !commentable.been_reviewed_by?(current_user)
  end

  def show_edit_link?(comment)
    comment.editable? && (comment.commenter.nil? || comment.commenter == current_user)
  end
end
