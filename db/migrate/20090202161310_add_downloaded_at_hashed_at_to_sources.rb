class AddDownloadedAtHashedAtToSources < ActiveRecord::Migration
  def self.up
    add_column :sources, :downloaded_at, :datetime
    add_column :sources, :hashed_at, :datetime
  end

  def self.down
    remove_column :sources, :hashed_at
    remove_column :sources, :downloaded_at
  end
end
