class RemoveOggTotally < ActiveRecord::Migration
  def self.up
    remove_column :sources, :ogg_preview_file_name
    remove_column :sources, :ogg_preview_content_type
    remove_column :sources, :ogg_preview_file_size
    remove_column :sources, :ogg_preview_updated_at
  end

  def self.down
    add_column :sources, :ogg_preview_file_name, :string
    add_column :sources, :ogg_preview_content_type, :string
    add_column :sources, :ogg_preview_file_size, :integer
    add_column :sources, :ogg_preview_updated_at, :datetime
  end
end
