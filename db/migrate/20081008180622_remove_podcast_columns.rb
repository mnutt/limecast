class RemovePodcastColumns < ActiveRecord::Migration
  def self.up
    remove_column 'podcasts', :feed_url
    remove_column 'podcasts', :feed_error
    remove_column 'podcasts', :feed_content
    remove_column 'podcasts', :itunes_link

    remove_column 'podcasts', :feed_etag
    remove_column 'podcasts', :state
  end

  def self.down
    add_column 'podcasts', :feed_url, :string
    add_column 'podcasts', :feed_error, :string
    add_column 'podcasts', :feed_content, :text
    add_column 'podcasts', :itunes_link, :string

    add_column 'podcasts', :feed_etag, :string
    add_column 'podcasts', :state, :string
  end
end
