module CommentsHelper
  def show_edit_link?(comment)
    comment.editable? && (comment.commenter.nil? || comment.commenter == current_user)
  end
end
