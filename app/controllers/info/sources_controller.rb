class Info::SourcesController < InfoController
  def show
    @podcast = Podcast.find_by_slug(params[:podcast_slug])
    @episode = @podcast.episodes.find_by_slug(params[:episode])
    @source = Source.find(params[:id])
    if newer_episode = @episode.next_episode
      @newer = newer_episode.sources.first
    end
    if older_episode = @episode.previous_episode
      @older = older_episode.sources.first
    end
  end
end
