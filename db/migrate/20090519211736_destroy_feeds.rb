class DestroyFeeds < ActiveRecord::Migration
  def self.up
    remove_index :feeds, :finder_id
    remove_index :feeds, :podcast_id
    remove_index :sources, :feed_id
    add_index    :sources, :podcast_id

    drop_table :feeds

    remove_column :podcasts, :primary_feed_id
    remove_column :queued_feeds, :feed_id
    remove_column :sources, :feed_id
    remove_column :statistics, :feeds_count
    remove_column :statistics, :feeds_found_by_admins_count
    rename_column :statistics, :feeds_from_trackers_count, :podcasts_from_trackers_count
  end

  def self.down
    create_table :feeds, :force => true do |t|
      t.string   "url"
      t.string   "error"
      t.string   "itunes_link"
      t.integer  "podcast_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "state", :default => "pending"
      t.integer  "bitrate"
      t.integer  "finder_id"
      t.string   "format"
      t.text     "xml", :limit => 16777215
      t.integer  "ability", :default => 0
      t.integer  "owner_id"
      t.string   "owner_email"
      t.string   "owner_name"
      t.string   "generator"
      t.string   "title"
      t.string   "description"
      t.string   "language"
      t.string   "logo_file_name"
      t.string   "logo_content_type"
      t.string   "logo_file_size"
    end

    add_column :podcasts, :primary_feed_id, :integer
    add_column :queued_feeds, :feed_id, :integer
    add_column :sources, :feed_id, :integer
    add_column :statistics, :feeds_count, :integer
    add_column :statistics, :feeds_found_by_admins_count, :integer
    add_column :statistics, :feeds_from_trackers_count, :podcasts_from_trackers_count, :integer

    add_index    :feeds, :finder_id
    add_index    :feeds, :podcast_id
    add_index    :sources, :feed_id
    remove_index :sources, :podcast_id
  end
end
