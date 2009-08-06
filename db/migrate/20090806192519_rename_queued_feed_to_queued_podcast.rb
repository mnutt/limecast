class RenameQueuedFeedToQueuedPodcast < ActiveRecord::Migration
  def self.up
    rename_table :queued_feeds, :queued_podcasts
  end

  def self.down
    rename_table :queued_podcasts, :queued_feeds
  end
end
