class AddFailedAtToDelayedJobs < ActiveRecord::Migration
  def self.up
    add_column :delayed_jobs, :failed_at, :datetime
  end

  def self.down
    remove_column :delayed_jobs, :failed_at
  end
end
