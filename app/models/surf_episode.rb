# == Schema Information
# Schema version: 20100504173954
#
# Table name: surf_episodes
#
#  id         :integer(4)    not null, primary key
#  episode_id :integer(4)    
#  order      :integer(4)    
#

class SurfEpisode < ActiveRecord::Base
  belongs_to :episode

  def self.reset_queue
    destroy_all
    Episode.all(:joins => :sources_with_preview_and_screenshot,
      :conditions => ["episodes.published_at >= ? AND episodes.published_at <= ?", 14.days.ago, Time.now],
      :order => "published_at DESC").sort_by { rand }.each do |e|
        create(:episode_id => e.id)
      end
  end

  def before_create
    self.order = SurfEpisode.maximum(:order).to_i + 1
  end

end
