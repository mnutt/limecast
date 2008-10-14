class AddBitrateToSource < ActiveRecord::Migration
  def self.up
    add_column :sources, :bitrate, :integer
  end

  def self.down
    remove_column :sources, :bitrate
  end
end
