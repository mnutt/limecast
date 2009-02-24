class AddAbilityToSources < ActiveRecord::Migration
  def self.up
    add_column :sources, :ability, :integer, :default => 0
  end

  def self.down
    remove_column :sources, :ability
  end
end
