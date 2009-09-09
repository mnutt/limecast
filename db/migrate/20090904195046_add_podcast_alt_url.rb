class AddPodcastAltUrl < ActiveRecord::Migration
  def self.up
    create_table :podcast_alt_urls, :force => true do |t|
      t.integer :podcast_id
      t.string :url
      t.timestamps
    end
  end

  def self.down
    drop_table :podcast_alt_urls
  end
end
