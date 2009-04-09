class Info::EpisodesController < InfoController
  def show
    @podcast = Podcast.find_by_slug(params[:podcast_slug])
    @episode = @podcast.episodes.find_by_slug(params[:episode])
    @newer   = @podcast.episodes.oldest.after(@episode).first
    @older   = @podcast.episodes.newest.before(@episode).first
  end
end

