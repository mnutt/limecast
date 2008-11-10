class CreateCommentRatings < ActiveRecord::Migration
  def self.up
    create_table :comment_ratings do |t|
      t.boolean :insightful

      t.integer :comment_id
      t.integer :user_id
    end
  end

  def self.down
    drop_table :comment_ratings
  end
end
