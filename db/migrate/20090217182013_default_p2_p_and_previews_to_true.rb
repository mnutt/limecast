class DefaultP2PAndPreviewsToTrue < ActiveRecord::Migration
  def self.up
    change_column :podcasts, :has_previews, :bool, :default => true
    change_column :podcasts, :has_p2p_acceleration, :bool, :default => true

    Podcast.all.each { |p| 
      p.update_attribute(:has_previews, true) if p.has_previews.nil?
      p.update_attribute(:has_p2p_acceleration, true) if p.has_p2p_acceleration.nil?
    }
  end

  def self.down
    change_column :podcasts, :has_previews, :default => false
    change_column :podcasts, :has_p2p_acceleration, :default => false
  end
end
