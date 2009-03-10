class SourcesController < ApplicationController
  def info
<<<<<<< HEAD:app/controllers/sources_controller.rb
    @podcast = Podcast.find_by_slug(params[:podcast_slug])
    @episode = @podcast.episodes.find_by_slug(params[:episode])
=======
    @podcast = Podcast.find_by_clean_url(params[:podcast_slug])
    @episode = @podcast.episodes.find_by_clean_url(params[:episode])
>>>>>>> 1d54dce415fcb9ece7febfca4ef0e36fb671404b:app/controllers/sources_controller.rb
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
