class AddApprovedToPodcasts < ActiveRecord::Migration
  def self.up
    add_column :podcasts, :approved, :boolean, :default => false
  end

  def self.down
    remove_column :podcasts, :approved
  end
end
