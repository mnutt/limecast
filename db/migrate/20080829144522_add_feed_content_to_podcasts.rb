class AddFeedContentToPodcasts < ActiveRecord::Migration
  def self.up
    rename_column :podcasts, :feed, :feed_url
    add_column :podcasts, :feed_content, :text
  end

  def self.down
    rename_column :podcasts, :feed_url, :feed
    remove_column :podcasts, :feed_content
  end
end
