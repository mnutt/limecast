class RemoveEpisodeColumnsAndAddDailyOrder < ActiveRecord::Migration
  def self.up
    remove_column :episodes, :date_title
    remove_column :episodes, :clean_url
    add_column :episodes, :daily_order, :integer, :default => 1
  end

  def self.down
    remove_column :episodes, :daily_order
    add_column :episodes, :clean_url, :string
    add_column :episodes, :date_title, :string
  end
end
