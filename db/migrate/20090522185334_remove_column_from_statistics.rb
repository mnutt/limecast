class RemoveColumnFromStatistics < ActiveRecord::Migration
  def self.up
    remove_column :statistics, :feeds_found_by_nonadmins_count
  end

  def self.down
    add_column :statistics, :feeds_found_by_nonadmins_count, :integer
  end
end
