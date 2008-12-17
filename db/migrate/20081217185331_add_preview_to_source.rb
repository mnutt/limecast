class AddPreviewToSource < ActiveRecord::Migration
  def self.up
    add_column :sources, :preview_file_name, :string
    add_column :sources, :preview_content_type, :string
    add_column :sources, :preview_file_size, :string
  end

  def self.down
    remove_column :sources, :preview_file_size
    remove_column :sources, :preview_content_type
    remove_column :sources, :preview_file_name
  end
end
