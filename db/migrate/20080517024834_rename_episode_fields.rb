class RenameEpisodeFields < ActiveRecord::Migration
  def self.up
    rename_column :episodes, :magnet, :enclosure_url
    rename_column :episodes, :synopsis, :summary
  end

  def self.down
  end
end
