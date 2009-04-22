class AddFavoritesCountToPodcasts < ActiveRecord::Migration
  def self.up
    add_column :podcasts, :favorites_count, :integer, :default => 0

    def Podcast.readonly_attributes; nil end # A little evil hack so we can save favorites_count

    # Refresh all the counter cached columns
    Podcast.all.each do |p|
      p.update_attribute :favorites_count, p.favorites.count
    end
  end

  def self.down
    remove_column :podcasts, :favorites_count
  end
end
