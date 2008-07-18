class AddSpecialToTags < ActiveRecord::Migration
  def self.up
    add_column :tags, :special, :boolean, :default => 0
  end

  def self.down
    remove_column :tags, :special
  end
end
