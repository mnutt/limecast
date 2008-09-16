class MakeCommentsForEpisodesOnly < ActiveRecord::Migration
  def self.up
    remove_column :comments, :commentable_type
    remove_column :comments, :commentable_id

    add_column :comments, :episode_id, :integer
  end

  def self.down
    remove_column :comments, :episode_id

    add_column :comments, :commentable_type, :string
    add_column :comments, :commentable_id, :integer
  end
end
