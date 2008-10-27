class AddFormatToFeed < ActiveRecord::Migration
  def self.up
    add_column :feeds, :format, :string
  end

  def self.down
    remove_column :feeds, :format
  end
end
