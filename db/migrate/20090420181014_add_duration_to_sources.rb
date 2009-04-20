class AddDurationToSources < ActiveRecord::Migration
  def self.up
    add_column :sources, :duration_from_ffmpeg, :integer
    add_column :sources, :duration_from_feed, :integer
  end

  def self.down
    remove_column :sources, :duration_from_feed
    remove_column :sources, :duration_from_ffmpeg
  end
end
