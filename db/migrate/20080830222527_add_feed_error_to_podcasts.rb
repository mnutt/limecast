class AddFeedErrorToPodcasts < ActiveRecord::Migration
  def self.up
    add_column :podcasts, :feed_error, :string
  end

  def self.down
    remove_column :podcasts, :feed_error
  end
end
