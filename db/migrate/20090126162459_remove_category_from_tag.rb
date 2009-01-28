class RemoveCategoryFromTag < ActiveRecord::Migration
  def self.up
    remove_column :tags, :category
  end

  def self.down
    add_column :tags, :category, :boolean
  end
end
