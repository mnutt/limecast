class AddArchivedToEpisode < ActiveRecord::Migration
  def self.up
    add_column :episodes, :archived, :boolean, :default => false
    remove_column :sources, :archived
  end

  def self.down
    remove_column :episodes, :archived
    add_column :sources, :archived, :boolean, :default => false
  end
end
