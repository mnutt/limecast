class AddRatingsToComment < ActiveRecord::Migration
  def self.up
    add_column :comments, :insightful, :integer, :default => 0
    add_column :comments, :not_insightful, :integer, :default => 0
  end

  def self.down
    remove_column :comments, :not_insightful
    remove_column :comments, :insightful
  end
end
