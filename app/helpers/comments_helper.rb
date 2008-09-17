module CommentsHelper
  def show_add_comment?(commentable)
    !commentable.been_reviewed_by?(current_user)
  end

  def show_edit_comment?(comment)
    comment.editable? && (comment.commenter.nil? || comment.commenter == current_user)
  end
end
