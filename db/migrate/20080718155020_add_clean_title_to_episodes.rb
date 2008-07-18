class AddCleanTitleToEpisodes < ActiveRecord::Migration
  def self.up
    add_column :episodes, :clean_title, :string
  end

  def self.down
    remove_column :episodes, :clean_title
  end
end
