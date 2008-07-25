class AddRatingToComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :positive, :boolean
  end

  def self.down
    remove_column :comments, :positive
  end
end
