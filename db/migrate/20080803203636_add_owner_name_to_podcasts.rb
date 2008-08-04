class AddOwnerNameToPodcasts < ActiveRecord::Migration
  def self.up
    add_column :podcasts, :owner_name, :string
  end

  def self.down
    remove_column :podcasts, :owner_name
  end
end
