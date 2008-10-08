class CreateFeedsTable < ActiveRecord::Migration
  def self.up
    create_table 'feeds' do |t|
      t.string :url
      t.string :error
      t.text   :content
      t.string :itunes_link

      t.integer :podcast_id

      t.timestamps
    end
  end

  def self.down
    drop_table 'feeds'
  end
end
