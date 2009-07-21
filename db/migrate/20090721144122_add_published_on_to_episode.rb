class AddPublishedOnToEpisode < ActiveRecord::Migration
  def self.up
    add_column :episodes, :published_on, :date
    Episode.find_each { |e|
      e.update_attribute :published_on, e.published_at.to_date
    }
  end

  def self.down
    remove_column :episodes, :published_on
  end
end
