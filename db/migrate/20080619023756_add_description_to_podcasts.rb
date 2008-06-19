class AddDescriptionToPodcasts < ActiveRecord::Migration
  def self.up
    add_column :podcasts, :description, :text
  end

  def self.down
    remove_column :podcasts, :description
  end
end
