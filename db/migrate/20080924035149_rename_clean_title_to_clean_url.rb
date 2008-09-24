class RenameCleanTitleToCleanUrl < ActiveRecord::Migration
  def self.up
    rename_column :podcasts, :clean_title, :clean_url
  end

  def self.down
    rename_column :podcasts, :clean_url, :clean_title
  end
end
