class DefaultP2PAndPreviewsToTrue < ActiveRecord::Migration
  def self.up
    change_column :podcasts, :has_previews, :bool, :default => true
    change_column :podcasts, :has_p2p_acceleration, :bool, :default => true

    update <<-EOS
      UPDATE podcasts SET has_previews = 1
      WHERE has_previews = NULL
    EOS

    update <<-EOS
      UPDATE podcasts SET has_p2p_acceleration = 1
      WHERE has_p2p_acceleration = NULL
    EOS
  end

  def self.down
    change_column :podcasts, :has_previews, :default => false
    change_column :podcasts, :has_p2p_acceleration, :default => false
  end
end
