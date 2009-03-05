class AddArchivedToSources < ActiveRecord::Migration
  def self.up
    add_column :sources, :archived, :boolean
  end

  def self.down
    remove_column :sources, :archived
  end
end
