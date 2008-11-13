class CommentRatingsToReviewRatings < ActiveRecord::Migration
  def self.up
    rename_table :comment_ratings, :review_ratings
    rename_column :review_ratings, :comment_id, :review_id
  end

  def self.down
    rename_column :review_ratings, :review_id, :comment_id
    rename_table :review_ratings, :comment_ratings
  end
end
