class AddRatingsToComment < ActiveRecord::Migration
  def self.up
    add_column :comments, :insightful, :integer
    add_column :comments, :not_insightful, :integer
  end

  def self.down
    remove_column :comments, :not_insightful
    remove_column :comments, :insightful
  end
end
