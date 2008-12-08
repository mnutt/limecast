class AddHashToSources < ActiveRecord::Migration
  def self.up
    add_column :sources, :hash, :string, :limit => 24
  end

  def self.down
    remove_column :sources, :hash
  end
end
