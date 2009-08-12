class AddCleanUrlToAuthor < ActiveRecord::Migration
  def self.up
    add_column :authors, :clean_url, :string
    add_index :authors, :clean_url
  end

  def self.down
    remove_index :authors, :clean_url
  end
end
