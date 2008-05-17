class AddEnclosureTypeToEpisodes < ActiveRecord::Migration
  def self.up
    add_column :episodes, :enclosure_type, :string
  end

  def self.down
    remove_column :episodes, :enclosure_type
  end
end
