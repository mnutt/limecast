class AddFeedRequestStatistic < ActiveRecord::Migration
  def self.up
    create_table :feed_request_statistics, :force => true do |t|
      t.string :feed_type
      t.string :ip_address
      t.string :user_agent
      t.string :referer
      t.integer :podcast_id
      t.timestamps
    end
  end

  def self.down
    drop_table :feed_request_statistics
  end
end
