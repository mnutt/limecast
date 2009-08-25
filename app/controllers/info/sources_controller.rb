class Info::SourcesController < InfoController
  def show
    @podcast = Podcast.find_by_slug(params[:podcast_slug])
    @episode = @podcast.episodes.find_by_slug(params[:episode])
    @source = Source.find(params[:id])
  end

  def index
    @filter = params[:filter].to_s
    @value = params[:value].to_s
    @limit = 100

    # forgive me for I have sinned by loading all these objects into memory ^o^
    @sources = case @value
               when "largest" then Source.all.reject { |s| s.bitrate.zero? }.sort_by(&:bitrate).reverse[0..@limit-1]
               when "smallest" then Source.all.reject { |s| s.bitrate.zero? }.sort_by(&:bitrate)[0..@limit-1]
               when "unknown" then Source.all.select { |s| s.bitrate.zero? }[0..@limit-1]
    end if @filter == 'bitrate'
  end
end
