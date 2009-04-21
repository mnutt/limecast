class AddFieldsToSources < ActiveRecord::Migration
  def self.up
    add_column :sources, :extension_from_feed, :string
    add_column :sources, :extension_from_disk, :string
    add_column :sources, :content_type_from_http, :string
    add_column :sources, :content_type_from_disk, :string
  end

  def self.down
    remove_column :sources, :content_type_from_disk
    remove_column :sources, :content_type_from_http
    remove_column :sources, :extension_from_disk
    remove_column :sources, :extension_from_feed
  end
end
