class RemoveP2PAndHasReviewsFromPodcast < ActiveRecord::Migration
  def self.up
    remove_column :podcasts, :has_previews
    remove_column :podcasts, :has_p2p_acceleration
  end

  def self.down
    add_column :podcasts, :has_previews, :bool
    add_column :podcasts, :has_p2p_acceleration, :bool
  end
end
