class CommentsToReviews < ActiveRecord::Migration
  def self.up
    rename_table :comments, :reviews
  end

  def self.down
    rename_table :reviews, :comments
  end
end
