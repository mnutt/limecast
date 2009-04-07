class AddFieldsToStatistic < ActiveRecord::Migration
  def self.up
    add_column :feeds,      :generator, :string # the podcast hosting software that generates the feed
    add_column :podcasts,   :button_installed, :boolean # the podcast has/doesn't have our button installed on their site
    
    add_column :statistics, :feeds_from_trackers_count, :integer
    add_column :statistics, :podcasts_with_buttons_count, :integer
    add_column :statistics, :podcasts_on_google_first_page_count, :integer
  end

  def self.down
    remove_column :statistics, :feeds_from_trackers_count
    remove_column :statistics, :podcasts_with_buttons_count
    remove_column :statistics, :podcasts_on_google_first_page_count
  end
end
