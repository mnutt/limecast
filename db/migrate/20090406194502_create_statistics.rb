class CreateStatistics < ActiveRecord::Migration
  def self.up
    create_table :statistics do |t|
      t.integer :podcasts_count
      t.integer :podcasts_found_by_admins_count
      t.integer :podcasts_found_by_nonadmins_count
      
      t.integer :feeds_count
      t.integer :feeds_found_by_admins_count
      t.integer :feeds_found_by_nonadmins_count
      
      t.integer :users_count
      t.integer :users_active_count
      t.integer :users_pending_count
      t.integer :users_passive_count
      
      t.integer :reviews_count
      
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :statistics
  end
end
