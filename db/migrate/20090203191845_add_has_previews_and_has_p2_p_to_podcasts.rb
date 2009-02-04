class AddHasPreviewsAndHasP2PToPodcasts < ActiveRecord::Migration
  def self.up
    add_column :podcasts, :has_previews, :bool
    add_column :podcasts, :has_p2p_acceleration, :bool
  end

  def self.down
    remove_column :podcasts, :has_previews
    remove_column :podcasts, :has_p2p_acceleration
  end
end
