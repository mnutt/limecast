class CreatePodcasts < ActiveRecord::Migration
  def self.up
    create_table :podcasts do |t|
      t.string :title
      t.string :site
      t.string :feed
      t.string :logo_file_name
      t.string :logo_content_type
      t.string :logo_file_size

      t.timestamps
    end
  end

  def self.down
    drop_table :podcasts
  end
end
