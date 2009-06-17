class RemoveApprovedFromPodcast < ActiveRecord::Migration
  def self.up
    remove_column :podcasts, :approved
  end

  def self.down
    add_column :podcasts, :approved, :boolean, :default => false
  end
end
