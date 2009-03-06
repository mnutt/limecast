class AddFramerateToSource < ActiveRecord::Migration
  def self.up
    add_column :sources, :framerate, :string, :limit => 20
  end

  def self.down
    remove_column :sources, :framerate
  end
end
