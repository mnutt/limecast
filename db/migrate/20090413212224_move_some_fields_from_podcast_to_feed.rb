class MoveSomeFieldsFromPodcastToFeed < ActiveRecord::Migration
  def self.up
    add_column :feeds, :title, :string
    add_column :feeds, :description, :string
    add_column :feeds, :language, :string

    Podcast.all.map { |p| p.primary_feed }.compact.each do |pf|
      pf.update_attribute(:title, pf.podcast.original_title)
      pf.update_attribute(:description, pf.podcast.description)
      pf.update_attribute(:language, pf.podcast.language)
    end

    remove_column :podcasts, :original_title
    remove_column :podcasts, :description
    remove_column :podcasts, :language
  end

  def self.down
    add_column :podcasts, :original_title, :string
    add_column :podcasts, :description, :string
    add_column :podcasts, :language, :string

    Podcast.all.each do |p|
      if p.primary_feed
        p.update_attribute(:original_title, p.primary_feed.title)
        p.update_attribute(:description, p.primary_feed.description)
        p.update_attribute(:language, p.primary_feed.language)
      end
    end

    remove_column :feeds, :title
    remove_column :feeds, :description
    remove_column :feeds, :language
  end
end
