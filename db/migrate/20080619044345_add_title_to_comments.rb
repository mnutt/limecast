class AddTitleToComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :title, :string
  end

  def self.down
    remove_column :comments, :title
  end
end
