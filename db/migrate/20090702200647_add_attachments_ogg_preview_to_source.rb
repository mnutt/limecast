class AddAttachmentsOggPreviewToSource < ActiveRecord::Migration
  def self.up
    add_column :sources, :ogg_preview_file_name, :string
    add_column :sources, :ogg_preview_content_type, :string
    add_column :sources, :ogg_preview_file_size, :integer
    add_column :sources, :ogg_preview_updated_at, :datetime
  end

  def self.down
    remove_column :sources, :ogg_preview_file_name
    remove_column :sources, :ogg_preview_content_type
    remove_column :sources, :ogg_preview_file_size
    remove_column :sources, :ogg_preview_updated_at
  end
end
