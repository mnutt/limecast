class AddFeedEtagToPodcasts < ActiveRecord::Migration
  def self.up
    add_column :podcasts, :feed_etag, :string
  end

  def self.down
    remove_column :podcasts, :feed_etag
  end
end
