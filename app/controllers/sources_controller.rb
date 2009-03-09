class SourcesController < ApplicationController
  def info
    @podcast = Podcast.find_by_slug(params[:podcast_slug])
    @episode = @podcast.episodes.find_by_clean_url(params[:episode])
    @source = Source.find(params[:id])
    @feed = @source.feed
    if newer_episode = @podcast.episodes.oldest.after(@episode).first
      @newer = newer_episode.sources.find_by_feed_id(@feed.id)
    end
    if older_episode = @podcast.episodes.newest.before(@episode).first
      @older = older_episode.sources.find_by_feed_id(@feed.id)
    end

    render :layout => 'info'
  end

end
