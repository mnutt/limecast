class AddPublishedAtToSources < ActiveRecord::Migration
  def self.up
    add_column :sources, :published_at, :datetime
  end

  def self.down
    remove_column :sources, :published_at
  end
end
