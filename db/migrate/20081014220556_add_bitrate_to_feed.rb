class AddBitrateToFeed < ActiveRecord::Migration
  def self.up
    add_column :feeds, :bitrate, :integer
  end

  def self.down
    remove_column :feeds, :bitrate
  end
end
