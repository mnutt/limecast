class AddCustomTitleToPodcast < ActiveRecord::Migration
  def self.up
    add_column :podcasts, :custom_title, :string, :default => ""

    Podcast.all.each do |p|
      p.title = nil
      p.save
    end
  end

  def self.down
    remove_column :podcasts, :custom_title
  end
end
