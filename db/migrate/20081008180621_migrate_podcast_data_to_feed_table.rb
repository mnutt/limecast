class MigratePodcastDataToFeedTable < ActiveRecord::Migration
  def self.up
    execute <<-SQL
      INSERT INTO feeds (url, error, content, itunes_link, podcast_id, created_at, updated_at)
      SELECT
        feed_url     AS url,
        feed_error   AS error,
        feed_content AS content,
        itunes_link,
        id           AS podcast_id,
        NOW()        AS created_at,
        NOW()        AS updated_at
      FROM podcasts;
    SQL
  end

  def self.down
  end
end
