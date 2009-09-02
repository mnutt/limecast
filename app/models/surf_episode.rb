class SurfEpisode < ActiveRecord::Base
  belongs_to :episode

  def self.reset_queue
    destroy_all
    Episode.all(:joins => :sources_with_preview_and_screenshot,
      :conditions => ["episodes.published_at >= ? AND episodes.published_at <= ?", 10.days.ago, Time.now],
      :order => "published_at DESC").sort_by { rand }.each do |e|
        create(:episode_id => e.id)
      end
  end

  def before_create
    self.order = SurfEpisode.maximum(:order).to_i + 1
  end

end