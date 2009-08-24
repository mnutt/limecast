class Info::EpisodesController < InfoController
  def show
    @podcast = Podcast.find_by_slug(params[:podcast_slug])
    @episode = @podcast.episodes.find_by_slug(params[:episode])
    @newer   = @episode.next_episode
    @older   = @episode.previous_episode
  end

  def recent
    @episodes = Episode.all(:include => :podcast, :conditions => ["created_at > ?", 24.hours.ago], :order => "created_at DESC")
  end
end

