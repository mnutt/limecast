# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090810141555) do

  create_table "authors", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "authors", ["email"], :name => "index_authors_on_email"
  add_index "authors", ["name"], :name => "index_authors_on_name"

  create_table "blacklists", :force => true do |t|
    t.string   "domain"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.string   "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "failed_at"
  end

  create_table "episodes", :force => true do |t|
    t.integer  "podcast_id"
    t.text     "summary"
    t.datetime "published_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "thumbnail_file_size"
    t.string   "thumbnail_file_name"
    t.string   "thumbnail_content_type"
    t.integer  "duration"
    t.string   "title"
    t.string   "guid"
    t.text     "xml"
    t.boolean  "archived",                                     :default => false
    t.text     "subtitle",               :limit => 2147483647
    t.integer  "daily_order",                                  :default => 1
    t.date     "published_on"
  end

  add_index "episodes", ["podcast_id"], :name => "index_episodes_on_podcast_id"

  create_table "favorites", :force => true do |t|
    t.integer  "user_id"
    t.integer  "podcast_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "favorites", ["podcast_id"], :name => "index_favorites_on_episode_id"
  add_index "favorites", ["user_id"], :name => "index_favorites_on_user_id"

  create_table "podcasts", :force => true do |t|
    t.string   "site"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "category_id"
    t.string   "clean_url"
    t.string   "title"
    t.boolean  "button_installed"
    t.boolean  "protected",                               :default => false
    t.integer  "favorites_count",                         :default => 0
    t.string   "url"
    t.string   "itunes_link"
    t.string   "state",                                   :default => "pending"
    t.integer  "bitrate"
    t.integer  "finder_id"
    t.string   "format"
    t.text     "xml"
    t.integer  "ability",                                 :default => 0
    t.string   "generator"
    t.string   "xml_title"
    t.text     "description",       :limit => 2147483647
    t.string   "language"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.string   "logo_file_size"
    t.string   "error"
    t.string   "custom_title",                            :default => ""
    t.text     "subtitle",          :limit => 2147483647
    t.string   "author_name"
    t.string   "author_email"
  end

  add_index "podcasts", ["clean_url"], :name => "index_podcasts_on_clean_url", :unique => true

  create_table "queued_podcasts", :force => true do |t|
    t.string   "url"
    t.string   "error"
    t.string   "state"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "podcast_id"
  end

  create_table "recommendations", :force => true do |t|
    t.integer  "podcast_id"
    t.integer  "related_podcast_id"
    t.integer  "weight"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "recommendations", ["podcast_id", "related_podcast_id"], :name => "index_recommendations_on_podcast_id_and_related_podcast_id", :unique => true

  create_table "review_ratings", :force => true do |t|
    t.boolean "insightful"
    t.integer "review_id"
    t.integer "user_id"
  end

  add_index "review_ratings", ["review_id"], :name => "index_review_ratings_on_review_id"

  create_table "reviews", :force => true do |t|
    t.integer  "user_id"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
    t.boolean  "positive"
    t.integer  "insightful",     :default => 0
    t.integer  "not_insightful", :default => 0
    t.integer  "podcast_id"
  end

  add_index "reviews", ["user_id"], :name => "index_reviews_on_user_id"

  create_table "sources", :force => true do |t|
    t.string   "url"
    t.string   "type"
    t.integer  "episode_id"
    t.string   "format"
    t.string   "screenshot_file_name"
    t.string   "screenshot_content_type"
    t.string   "screenshot_file_size"
    t.string   "preview_file_name"
    t.string   "preview_content_type"
    t.string   "preview_file_size"
    t.integer  "height"
    t.integer  "width"
    t.datetime "downloaded_at"
    t.datetime "hashed_at"
    t.text     "curl_info"
    t.text     "ffmpeg_info"
    t.string   "file_name"
    t.string   "torrent_file_name"
    t.string   "torrent_content_type"
    t.string   "torrent_file_size"
    t.string   "random_clip_file_name"
    t.string   "random_clip_content_type"
    t.string   "random_clip_file_size"
    t.integer  "ability",                                :default => 0
    t.string   "framerate",                :limit => 20
    t.integer  "size_from_xml"
    t.integer  "size_from_disk"
    t.string   "sha1hash",                 :limit => 40
    t.text     "torrent_info"
    t.integer  "duration_from_ffmpeg"
    t.integer  "duration_from_feed"
    t.string   "extension_from_feed"
    t.string   "extension_from_disk"
    t.string   "content_type_from_http"
    t.string   "content_type_from_disk"
    t.string   "content_type_from_feed"
    t.datetime "published_at"
    t.integer  "podcast_id"
    t.integer  "bitrate_from_feed"
    t.integer  "bitrate_from_ffmpeg"
    t.datetime "created_at"
    t.string   "ogg_preview_file_name"
    t.string   "ogg_preview_content_type"
    t.integer  "ogg_preview_file_size"
    t.datetime "ogg_preview_updated_at"
  end

  add_index "sources", ["episode_id"], :name => "index_sources_on_episode_id"
  add_index "sources", ["podcast_id"], :name => "index_sources_on_podcast_id"

  create_table "statistics", :force => true do |t|
    t.integer  "podcasts_count"
    t.integer  "podcasts_found_by_admins_count"
    t.integer  "podcasts_found_by_nonadmins_count"
    t.integer  "users_count"
    t.integer  "users_confirmed_count"
    t.integer  "users_unconfirmed_count"
    t.integer  "users_passive_count"
    t.integer  "reviews_count"
    t.datetime "created_at"
    t.integer  "podcasts_from_trackers_count"
    t.integer  "podcasts_with_buttons_count"
    t.integer  "podcasts_on_google_first_page_count"
    t.integer  "users_admins_count"
    t.integer  "users_nonadmins_count"
    t.integer  "users_makers_count"
    t.integer  "reviews_by_admins_count"
    t.integer  "reviews_by_nonadmins_count"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "podcast_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id_and_taggable_type"
  add_index "taggings", ["tag_id"], :name => "index_taggings_on_user_id_and_tag_id_and_taggable_type"

  create_table "tags", :force => true do |t|
    t.string  "name"
    t.boolean "badge"
    t.boolean "blacklisted"
    t.integer "map_to_id"
    t.integer "taggings_count"
  end

  create_table "user_taggings", :force => true do |t|
    t.integer "user_id"
    t.integer "tagging_id"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
    t.datetime "deleted_at"
    t.boolean  "admin"
    t.string   "reset_password_code"
    t.datetime "reset_password_sent_at"
    t.integer  "score",                                   :default => 0
    t.datetime "logged_in_at"
    t.boolean  "confirmed",                               :default => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["login"], :name => "index_users_on_login", :unique => true

end
