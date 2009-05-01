class Info::ReviewsController < InfoController
  def show
    @podcast = Podcast.find_by_slug(params[:podcast_slug])
    @review = @podcast.reviews.find(params[:id])

    render :layout => 'info'
  end
end

