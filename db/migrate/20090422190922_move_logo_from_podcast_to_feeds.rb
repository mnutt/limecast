class MoveLogoFromPodcastToFeeds < ActiveRecord::Migration
  def self.up
    add_column :feeds, :logo_file_name, :string
    add_column :feeds, :logo_content_type, :string
    add_column :feeds, :logo_file_size, :string

    say_with_time "Setting primary_feed logos as their current podcast's logo" do
      Podcast.all.each do |podcast|
        if podcast.logo.file? && f = podcast.primary_feed
          f.attachment_for(:logo).assign podcast.attachment_for(:logo)
          f.save
        end
      end
    end
  end

  def self.down
    remove_column :feeds, :logo_file_name
    remove_column :feeds, :logo_content_type
    remove_column :feeds, :logo_file_size
  end
end
