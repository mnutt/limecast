class Info::PodcastsController < InfoController
  def show
    @podcast = Podcast.find_by_slug(params[:podcast_slug])
  end
end

