module CommentsHelper
  def can_add_comments?(episode)
    comment_in_session = Comment.find(:all, session.data[:comments]).map(&:episode_id).includes?(episode.id)

    if current_user.nil?
      !comment_in_session && episode.open_for_comments?
    else
      !episode.been_reviewed_by?(current_user) && episode.open_for_comments?
    end
  end

  def can_edit_comment?(comment)
    comment.editable? && comment.commenter == current_user
  end
end
