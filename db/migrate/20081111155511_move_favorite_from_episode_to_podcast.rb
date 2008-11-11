class MoveFavoriteFromEpisodeToPodcast < ActiveRecord::Migration
  def self.up
    Favorite.destroy_all # the Episodes won't translate 1-to-1 with Podcasts
    rename_column :favorites, :episode_id, :podcast_id
  end

  def self.down
    rename_column :favorites, :podcast_id, :episode_id
  end
end
