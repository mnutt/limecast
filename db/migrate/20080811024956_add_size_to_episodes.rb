class AddSizeToEpisodes < ActiveRecord::Migration
  def self.up
    add_column :episodes, :enclosure_size, :integer
  end

  def self.down
    remove_column :episodes, :enclosure_size
  end
end
