class CreateEpisodes < ActiveRecord::Migration
  def self.up
    create_table :episodes do |t|
      t.integer :podcast_id
      t.integer :title
      t.text :synopsis
      t.string :magnet
      t.datetime :published_at

      t.timestamps
    end
  end

  def self.down
    drop_table :episodes
  end
end
