class MoveGuidFromSourceToEpisode < ActiveRecord::Migration
  def self.up
    remove_column :sources, :guid
    add_column    :episodes, :guid, :string
  end

  def self.down
    add_column    :sources, :guid, :string
    remove_column :episodes, :guid
  end
end
