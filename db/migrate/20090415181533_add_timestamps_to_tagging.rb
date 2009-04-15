class AddTimestampsToTagging < ActiveRecord::Migration
  def self.up
    add_column :taggings, :created_at, :datetime 
    add_column :taggings, :updated_at, :datetime 
  end

  def self.down
    remove_column :taggings, :created_at
    remove_column :taggings, :updated_at
  end
end
