class ChangeStateNames < ActiveRecord::Migration
  def self.up
    rename_column :statistics, :users_active_count, :users_confirmed_count
    rename_column :statistics, :users_pending_count, :users_unconfirmed_count
    execute 'UPDATE users SET state = "unconfirmed" WHERE state = "pending";'
    execute 'UPDATE users SET state = "confirmed"   WHERE state = "active";'
  end

  def self.down
    rename_column :statistics, :users_confirmed_count, :users_active_count
    rename_column :statistics, :users_unconfirmed_count, :users_pending_count
    execute 'UPDATE users SET state = "pending" WHERE state = "unconfirmed";'
    execute 'UPDATE users SET state = "active"  WHERE state = "confirmed";'
  end
end
