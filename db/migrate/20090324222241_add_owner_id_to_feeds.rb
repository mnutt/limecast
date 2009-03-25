class AddOwnerIdToFeeds < ActiveRecord::Migration
  def self.up
    add_column :feeds, :owner_id, :integer
    add_column :feeds, :owner_email, :string
    add_column :feeds, :owner_name, :string
  end

  def self.down
    remove_column :feeds, :owner_name
    remove_column :feeds, :owner_email
    remove_column :feeds, :owner_id
  end
end
