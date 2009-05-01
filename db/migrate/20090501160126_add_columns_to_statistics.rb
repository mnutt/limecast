class AddColumnsToStatistics < ActiveRecord::Migration
  def self.up
    add_column :statistics, :users_admins_count, :integer
    add_column :statistics, :users_nonadmins_count, :integer
    add_column :statistics, :users_makers_count, :integer
    add_column :statistics, :reviews_by_admins_count, :integer
    add_column :statistics, :reviews_by_nonadmins_count, :integer
  end

  def self.down
    remove_column :statistics, :users_admins_count
    remove_column :statistics, :users_nonadmins_count
    remove_column :statistics, :users_makers_count
    remove_column :statistics, :reviews_by_admins_count
    remove_column :statistics, :reviews_by_nonadmins_count
  end
end
