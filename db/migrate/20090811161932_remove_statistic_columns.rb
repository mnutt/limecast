class RemoveStatisticColumns < ActiveRecord::Migration
  def self.up
    remove_column :statistics, :users_passive_count
    rename_column :statistics, :users_makers_count, :authors_count
  end

  def self.down
    rename_column :statistics, :authors_count, :users_makers_count
    add_column :statistics, :users_passive_count, :integer
  end
end
