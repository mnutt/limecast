class AddStateToFeed < ActiveRecord::Migration
  def self.up
    add_column :feeds, :state, :string, :default => 'pending'
  end

  def self.down
    remove_column :feeds, :state
  end
end
