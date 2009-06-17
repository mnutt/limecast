class Admin::PodcastsController < AdminController
  layout "info"

  def index
    @podcasts = Podcast.all
  end

  def blacklist
    @podcast = Podcast.find_by_slug(params[:podcast_slug])
    @podcast.blacklist!

    redirect_to :action => :index
  end
end
