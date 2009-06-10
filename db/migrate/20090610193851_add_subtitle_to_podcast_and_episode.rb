class AddSubtitleToPodcastAndEpisode < ActiveRecord::Migration
  def self.up
    add_column :podcasts, :subtitle, :string
    add_column :episodes, :subtitle, :string
  end

  def self.down
    remove_column :podcasts, :subtitle
    remove_column :episodes, :subtitle
  end
end
