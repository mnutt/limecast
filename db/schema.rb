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

ActiveRecord::Schema.define(:version => 20090219182742) do

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
    t.string   "clean_url"
  end

  create_table "favorites", :force => true do |t|
    t.integer  "user_id"
    t.integer  "podcast_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "favorites", ["podcast_id"], :name => "index_favorites_on_episode_id"
  add_index "favorites", ["user_id"], :name => "index_favorites_on_user_id"

  create_table "feeds", :force => true do |t|
    t.string   "url"
    t.string   "error"
    t.string   "itunes_link"
    t.integer  "podcast_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state",                           :default => "pending"
    t.integer  "bitrate"
    t.integer  "finder_id"
    t.string   "format"
    t.text     "xml",         :limit => 16777215
  end

  add_index "feeds", ["finder_id"], :name => "index_feeds_on_finder_id"
  add_index "feeds", ["podcast_id"], :name => "index_feeds_on_podcast_id"

  create_table "podcasts", :force => true do |t|
    t.string   "original_title"
    t.string   "site"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.string   "logo_file_size"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.string   "language"
    t.integer  "category_id"
    t.string   "clean_url"
    t.integer  "owner_id"
    t.string   "owner_email"
    t.string   "owner_name"
    t.string   "title"
    t.integer  "primary_feed_id"
    t.boolean  "has_previews",         :default => true
    t.boolean  "has_p2p_acceleration", :default => true
  end

  add_index "podcasts", ["clean_url"], :name => "index_podcasts_on_clean_url", :unique => true
  add_index "podcasts", ["owner_id"], :name => "index_podcasts_on_owner_id"

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
    t.integer  "episode_id"
    t.integer  "insightful",     :default => 0
    t.integer  "not_insightful", :default => 0
  end

  add_index "reviews", ["episode_id"], :name => "index_reviews_on_episode_id"
  add_index "reviews", ["user_id"], :name => "index_reviews_on_user_id"

  create_table "sources", :force => true do |t|
    t.string   "url"
    t.string   "type"
    t.string   "guid"
    t.integer  "episode_id"
    t.string   "format"
    t.integer  "feed_id"
    t.string   "sha1hash",                :limit => 24
    t.string   "screenshot_file_name"
    t.string   "screenshot_content_type"
    t.string   "screenshot_file_size"
    t.string   "preview_file_name"
    t.string   "preview_content_type"
    t.string   "preview_file_size"
    t.integer  "size",                    :limit => 8
    t.integer  "height"
    t.integer  "width"
    t.text     "xml"
    t.datetime "downloaded_at"
    t.datetime "hashed_at"
    t.text     "curl_info"
    t.text     "ffmpeg_info"
    t.string   "file_name"
  end

  add_index "sources", ["episode_id"], :name => "index_sources_on_episode_id"
  add_index "sources", ["feed_id"], :name => "index_sources_on_feed_id"

  create_table "taggings", :force => true do |t|
    t.integer "tag_id"
    t.integer "podcast_id"
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
    t.string   "state",                                   :default => "passive"
    t.datetime "deleted_at"
    t.boolean  "admin"
    t.string   "reset_password_code"
    t.datetime "reset_password_sent_at"
    t.integer  "score",                                   :default => 0
    t.datetime "logged_in_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["login"], :name => "index_users_on_login", :unique => true

end
