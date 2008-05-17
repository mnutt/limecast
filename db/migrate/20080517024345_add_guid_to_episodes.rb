class AddGuidToEpisodes < ActiveRecord::Migration
  def self.up
    add_column :episodes, :guid, :string
  end

  def self.down
    remove_column :episodes, :guid
  end
end
