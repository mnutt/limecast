class AddFieldsToPodcastAltUrl < ActiveRecord::Migration
  def self.up
    add_column :podcast_alt_urls, :bitrate, :integer
    add_column :podcast_alt_urls, :size, :integer
    add_column :podcast_alt_urls, :extension, :string
  end

  def self.down
    remove_column :podcast_alt_urls, :bitrate
    remove_column :podcast_alt_urls, :size
    remove_column :podcast_alt_urls, :extension
  end
end
