class ChangeEpisodeTitleToString < ActiveRecord::Migration
  def self.up
    remove_column :episodes, :title
    add_column :episodes, :title, :string
  end

  def self.down
  end
end
