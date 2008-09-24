class AddCustomTitleToPodcasts < ActiveRecord::Migration
  def self.up
    add_column :podcasts, :custom_title, :string
  end

  def self.down
    remove_column :podcasts, :custom_title
  end
end
