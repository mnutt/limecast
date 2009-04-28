class AddEpisodePodcastIdIndex < ActiveRecord::Migration
  def self.up
    add_index :episodes, :podcast_id
  end

  def self.down
    remove_index :episodes, :podcast_id
  end
end
