class AddTorrentInfoToSources < ActiveRecord::Migration
  def self.up
    add_column :sources, :torrent_info, :text
  end

  def self.down
    remove_column :sources, :torrent_info
  end
end
