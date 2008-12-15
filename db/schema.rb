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

ActiveRecord::Schema.define(:version => 20081215171837) do

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

  add_index "favorites", ["user_id"], :name => "index_favorites_on_user_id"
  add_index "favorites", ["podcast_id"], :name => "index_favorites_on_episode_id"

  create_table "feeds", :force => true do |t|
    t.string   "url"
    t.string   "error"
    t.string   "itunes_link"
    t.integer  "podcast_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state",       :default => "pending"
    t.integer  "bitrate"
    t.integer  "finder_id"
    t.string   "format"
  end

  create_table "podcasts", :force => true do |t|
    t.string   "title"
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
    t.string   "custom_title"
    t.integer  "primary_feed_id"
  end

  create_table "review_ratings", :force => true do |t|
    t.boolean "insightful"
    t.integer "review_id"
    t.integer "user_id"
  end

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

  create_table "sources", :force => true do |t|
    t.string  "url"
    t.string  "type"
    t.string  "guid"
    t.integer "size"
    t.integer "episode_id"
    t.string  "format"
    t.integer "feed_id"
    t.string  "sha1hash",                :limit => 24
    t.string  "screenshot_file_name"
    t.string  "stringshot_content_type"
    t.string  "stringshot_file_size"
  end

  create_table "taggings", :force => true do |t|
    t.integer "tag_id"
    t.integer "taggable_id"
    t.string  "taggable_type"
  end

  add_index "taggings", ["tag_id", "taggable_type"], :name => "index_taggings_on_tag_id_and_taggable_type"
  add_index "taggings", ["tag_id", "taggable_type"], :name => "index_taggings_on_user_id_and_tag_id_and_taggable_type"
  add_index "taggings", ["taggable_id", "taggable_type"], :name => "index_taggings_on_taggable_id_and_taggable_type"
  add_index "taggings", ["taggable_id", "taggable_type"], :name => "index_taggings_on_user_id_and_taggable_id_and_taggable_type"

  create_table "tags", :force => true do |t|
    t.string  "name"
    t.boolean "badge"
    t.boolean "blacklisted"
    t.boolean "category"
    t.integer "map_to_id"
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
  end

end
