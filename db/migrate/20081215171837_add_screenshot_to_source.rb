class AddScreenshotToSource < ActiveRecord::Migration
  def self.up
    add_column :sources, :screenshot_file_name, :string
    add_column :sources, :stringshot_content_type, :string
    add_column :sources, :stringshot_file_size, :string
  end

  def self.down
    remove_column :sources, :stringshot_file_size
    remove_column :sources, :stringshot_content_type
    remove_column :sources, :screenshot_file_name
  end
end
