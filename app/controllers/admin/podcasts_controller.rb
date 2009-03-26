class Admin::PodcastsController < AdminController
  layout "info"

  def index
    @podcasts = Podcast.not_approved
  end

  def approve
    @podcasts = Podcast.update_all({:approved => true}, {:id => params[:podcast][:id]})

    redirect_to :action => :index
  end

  def blacklist
    @podcast = Podcast.find_by_slug(params[:podcast_slug])
    @podcast.blacklist!

    redirect_to :action => :index
  end
end
