class AddDateTitleToEpisode < ActiveRecord::Migration
  def self.up
    add_column :episodes, :date_title, :string

    Episode.find_each do |episode|
      episode.generate_date_title
      episode.generate_url
      # say "Generating :date_title #{episode.date_title} for podcast ##{episode.podcast_id}"
      episode.save
    end
  end

  def self.down
    remove_column :episodes, :date_title
  end
end
