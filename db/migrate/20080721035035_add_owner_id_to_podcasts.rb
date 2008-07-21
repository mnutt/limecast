class AddOwnerIdToPodcasts < ActiveRecord::Migration
  def self.up
    add_column :podcasts, :owner_id, :integer
  end

  def self.down
    remove_column :podcasts, :owner_id
  end
end
