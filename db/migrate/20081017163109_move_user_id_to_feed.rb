class MoveUserIdToFeed < ActiveRecord::Migration
  def self.up
    add_column :feeds, 'finder_id', :integer

    execute <<-SQL
      UPDATE feeds
      SET    feeds.finder_id = (
        SELECT user_id
        FROM   podcasts
        WHERE  podcasts.id = feeds.podcast_id
      );
    SQL

    remove_column :podcasts, 'user_id'
  end

  def self.down
    add_column :podcasts, 'finder_id', :integer
    remove_column :feeds, 'user_id'
  end
end
