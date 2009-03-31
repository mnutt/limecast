class CreateQueuedFeedsTable < ActiveRecord::Migration
  def self.up
    create_table :queued_feeds do |t|
      t.string :url
      t.string :error
      t.string :state
      t.integer :feed_id

      t.timestamps
    end
  end

  def self.down
    drop_table :queued_feeds
  end
end
