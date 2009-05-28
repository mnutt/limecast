class AddBitrateToSources < ActiveRecord::Migration
  def self.up
    add_column :sources, :bitrate_from_feed, :integer
    add_column :sources, :bitrate_from_ffmpeg, :integer
  end

  def self.down
    remove_column :sources, :bitrate_from_feed
    remove_column :sources, :bitrate_from_ffmpeg
  end
end
