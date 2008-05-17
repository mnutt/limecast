class AddDurationToEpisodes < ActiveRecord::Migration
  def self.up
    add_column :episodes, :duration, :integer
  end

  def self.down
    remove_column :episodes, :duration
  end
end
