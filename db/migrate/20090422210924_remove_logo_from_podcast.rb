class RemoveLogoFromPodcast < ActiveRecord::Migration
  def self.up
    remove_column :podcasts, :logo_file_name
    remove_column :podcasts, :logo_content_type
    remove_column :podcasts, :logo_file_size
  end

  def self.down
    add_column :podcasts, :logo_file_name, :string
    add_column :podcasts, :logo_content_type, :string
    add_column :podcasts, :logo_file_size, :string
  end
end
