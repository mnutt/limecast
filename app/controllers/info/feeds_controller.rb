class Info::FeedsController < InfoController
  def show
    @feed = Feed.find(params[:id])

    render :layout => 'info'
  end
end
