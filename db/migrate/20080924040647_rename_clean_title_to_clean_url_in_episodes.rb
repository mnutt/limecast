class RenameCleanTitleToCleanUrlInEpisodes < ActiveRecord::Migration
  def self.up
    rename_column :episodes, :clean_title, :clean_url
  end

  def self.down
    rename_column :episodes, :clean_url, :clean_title
  end
end
