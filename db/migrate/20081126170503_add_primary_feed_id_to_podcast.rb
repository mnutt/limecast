class AddPrimaryFeedIdToPodcast < ActiveRecord::Migration
  def self.up
    add_column :podcasts, :primary_feed_id, :integer
    Podcast.all.each do |pod|
      if pod.primary_feed_id.nil? && primary_feed = pod.feeds.first
        pod.update_attribute :primary_feed_id, primary_feed.id
      end
    end
  end

  def self.down
    remove_column :podcasts, :primary_feed_id
  end
end
