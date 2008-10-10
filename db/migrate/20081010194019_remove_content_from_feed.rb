class RemoveContentFromFeed < ActiveRecord::Migration
  def self.up
    remove_column :feeds, :content
  end

  def self.down
    add_column :feeds, :content, :text
  end
end
