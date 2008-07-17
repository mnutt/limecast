class AddCleanTitleToPodcasts < ActiveRecord::Migration
  def self.up
    add_column :podcasts, :clean_title, :string
  end

  def self.down
    remove_column :podcasts, :clean_title
  end
end
