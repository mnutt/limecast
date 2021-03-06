class PodcastsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => :status
  before_filter :login_required, :only => [:edit, :update, :destroy]

  # GET /all.xml
  def index
    @podcasts = Podcast.sorted
    respond_to(:html, :xml)
  end

  # GET /popular.xml
  def popular
    @podcasts = Podcast.popular.paginate(
      :page => (params[:page] || 1),
      :per_page => params[:limit] || 10
    )

    respond_to do |format|
      format.html
      format.xml { render :index }
    end
  end
  
  # GET /recently_updated.xml
  def recently_updated
    @podcasts = Episode.sorted.paginate(
      :per_page => 10, 
      :page => 1, 
      :group => :podcast_id
    ).map(&:podcast)

    respond_to do |format|
      format.xml { render :index }
    end
  end

  # GET /add
  def new
    @podcast = Podcast.new
  end

  # GET /:podcast_slug
  def show
    @podcast ||= Podcast.find_by_slug(params[:podcast_slug])
    @favorited = current_user && current_user.favorite_podcasts.include?(@podcast)

    @episode = @podcast.newest_episode

    @episodes = @podcast.episodes.all(:include => :sources, :limit => 3, :order => "published_at DESC")
    @related  = @podcast.related_podcasts
    @reviews  = @podcast.reviews.claimed
    @review   = @podcast.reviews.build
  end

  # GET /:podcast_slug/cover
  def cover
    @podcast ||= Podcast.find_by_slug(params[:podcast_slug])
  end

  # GET /plain_feeds/:id.xml
  # GET /torrent_feeds/:id.xml
  # GET /magnet_feeds/:id.xml
  def feed
    @podcast = Podcast.find(params[:id])

    # log the request
    frs = FeedRequestStatistic.create(:podcast_id => @podcast.id,
                                      :feed_type  => params[:type].to_s,
                                      :ip_address => request.remote_ip,
                                      :user_agent => request.env["HTTP_USER_AGENT"],
                                      :referer    => request.referer)

    render :xml => @podcast.as(params[:type])
  end

  # GET /:podcast_slug
  def status
    @queued_podcast = QueuedPodcast.by_url(params[:podcast]).first
    @podcast        = @queued_podcast.podcast if @queued_podcast

    # See http://wiki.limewire.org/index.php?title=LimeCast_Add#Messages
    # Unexpected errors
    if @queued_podcast.nil?
      render :partial => 'status_error'
    # Successes
    elsif @podcast && @queued_podcast.parsed? && queued_podcast_created_just_now_by_user?(@queued_podcast)
      render :partial => 'status_added'
    elsif @podcast && @queued_podcast.parsed?
      render :partial => 'status_conflict'
    # Progress
    elsif @queued_podcast.pending?
      render :partial => 'status_loading'
    # Expected errors
    elsif @queued_podcast.failed?
      render :partial => 'status_failed'
    # Really unexpected errors
    else
      render :partial => 'status_error'
    end
  end
  
  # POST /podcasts?url=...
  def create
    @queued_podcast = QueuedPodcast.find_or_initialize_by_url(params[:podcast][:url])

    if @queued_podcast.new_record?
      @queued_podcast.save
      remember_unclaimed_record(@queued_podcast)
    else
      @queued_podcast.save
    end

    render :nothing => true
  end

  
  # DELETE /:podcast_slug
  def destroy
    @podcast = Podcast.find_by_slug(params[:podcast_slug])
    authorize_write @podcast

    @podcast.destroy

    redirect_to(podcasts_url)
  end

  # TODO we should refactor/DRY up this method
  def update
    @podcast = Podcast.find_by_slug(params[:podcast_slug])

    authorize_write @podcast

    # The "_delete" attr is taken from Nested Association Attributes, but AR doesn't support
    # it on a regular model, so we're going to use the same convention when deleting the Podcast.
    if params[:podcast] && params[:podcast][:_delete] == '1'
      @podcast.destroy
      redirect_to(podcasts_url) and return false
    end

    # Set user-specific Podcast attributes if necessary
    params[:podcast][:tag_string] = [params[:podcast][:tag_string], current_user] if params[:podcast][:tag_string]

    @podcast.attributes = params[:podcast].slice(:protected, :tag_string, :custom_title, :format, :itunes_link)


    respond_to do |format|
      if @podcast.save
        format.html do
          flash[:has_messages] = true unless @podcast.messages.empty?
          redirect_to @podcast
        end
        format.js { render :text => render_to_string(:partial => 'podcasts/form') }
      else
        format.html {
          show; render :action => 'show'
        }
        format.js { head(:failure) }
      end
    end
  end

  def favorite
    @podcast = Podcast.find_by_slug(params[:podcast_slug])

    unless has_unclaimed_record?(Favorite, lambda {|f| f.podcast == @podcast })
      @favorite = Favorite.find_or_initialize_by_podcast_id_and_user_id(@podcast.id, (current_user.id rescue nil))
      if @favorite.new_record?
        @favorite.save
        remember_unclaimed_record(@favorite)
      else
        @favorite.destroy
      end
    end

    respond_to do |format|
      format.html { redirect_back_or_default('/') }
      format.json { render :json => {:logged_in => logged_in?} }
    end
  end


  protected

    def queued_podcast_in_session?(queued_podcast)
      has_unclaimed_record?(QueuedPodcast, lambda {|i| i.id == queued_podcast.id })
    end

    def queued_podcast_created_by_user?(queued_podcast)
      queued_podcast_in_session?(queued_podcast) or queued_podcast.user == current_user
    end

    def queued_podcast_created_just_now_by_user?(queued_podcast)
      queued_podcast_created_by_user?(queued_podcast) && queued_podcast.created_at > 2.minutes.ago
    end
end
