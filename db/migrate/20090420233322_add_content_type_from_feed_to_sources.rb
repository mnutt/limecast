class AddContentTypeFromFeedToSources < ActiveRecord::Migration
  def self.up
    add_column :sources, :content_type_from_feed, :string
  end

  def self.down
    remove_column :sources, :content_type_from_feed
  end
end
