class AddThumbnailToEpisode < ActiveRecord::Migration
  def self.up
    add_column :episodes, :thumbnail_file_size, :integer
    add_column :episodes, :thumbnail_file_name, :string
    add_column :episodes, :thumbnail_content_type, :string
  end

  def self.down
    remove_column :episodes, :thumbnail_content_type
    remove_column :episodes, :thumbnail_file_name
    remove_column :episodes, :thumbnail_file_size
  end
end
