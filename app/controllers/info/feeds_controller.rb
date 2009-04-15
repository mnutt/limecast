class Info::FeedsController < InfoController
  def show
    @feed = Feed.find(params[:id])
    @feed_xml = @feed.diagnostic_xml

    render :layout => 'info'
  end
end

