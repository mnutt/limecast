class MoveXmlFromSourceToEpisode < ActiveRecord::Migration
  def self.up
    add_column :episodes, :xml, :text

    Episode.find_each do |episode|
      if source = episode.sources.first
        episode.update_attribute(:xml, source.xml)
      end
    end

    remove_column :sources, :xml
  end

  def self.down
    add_column :sources, :xml, :text

    Episode.find_each do |episode|
      episode.sources.each do |source|
        source.update_attribute(:xml, episode.xml) if source.xml.blank?
      end
    end

    remove_column :episodes, :xml
  end
end
