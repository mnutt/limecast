class Admin::PodcastsController < AdminController
  layout "info"

  def index
    @podcasts = Podcast.find(:all)
  end

  def approve
    @podcast = Podcast.find_by_clean_url(params[:podcast_slug])
    @podcast.update_attributes(:approved => true)

    redirect_to :action => :index
  end
end
