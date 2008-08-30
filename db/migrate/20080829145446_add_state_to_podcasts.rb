class AddStateToPodcasts < ActiveRecord::Migration
  def self.up
    add_column :podcasts, :state, :string
  end

  def self.down
    remove_column :podcasts, :state
  end
end
