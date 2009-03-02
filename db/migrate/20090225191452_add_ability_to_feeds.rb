class AddAbilityToFeeds < ActiveRecord::Migration
  def self.up
    add_column :feeds, :ability, :integer, :default => 0
  end

  def self.down
    remove_column :feeds, :ability
  end
end
