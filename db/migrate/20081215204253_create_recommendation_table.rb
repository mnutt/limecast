class CreateRecommendationTable < ActiveRecord::Migration
  def self.up
    create_table :recommendations do |t|
      t.integer :podcast_id
      t.integer :related_podcast_id
      t.integer :weight

      t.timestamps
    end
  end

  def self.down
    drop_table :recommendations
  end
end
