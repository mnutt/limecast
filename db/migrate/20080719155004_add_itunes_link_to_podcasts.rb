class AddItunesLinkToPodcasts < ActiveRecord::Migration
  def self.up
    add_column :podcasts, :itunes_link, :string
  end

  def self.down
    remove_column :podcasts, :itunes_link
  end
end
