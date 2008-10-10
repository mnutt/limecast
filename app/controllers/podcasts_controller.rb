class PodcastsController < ApplicationController
  before_filter :login_required, :only => [:edit, :update, :destroy]
  skip_before_filter :verify_authenticity_token, :only => :status

  def index
    @podcasts = Podcast.parsed.find(:all, :order => "title ASC")
  end

  def show
    raise ActiveRecord::RecordNotFound if params[:podcast].nil?
    @podcast = Podcast.find_by_clean_url(params[:podcast]) or raise ActiveRecord::RecordNotFound
    @episodes = @podcast.episodes.find(:all, :order => "published_at DESC", :limit => 3)

    @comments = with(@podcast.episodes.newest.first) {|ep| ep.nil? ? [] : ep.comments }
    @comment  = Comment.new(:episode => @podcast.episodes.newest.first)
  end

  def search
    if params[:q]
      redirect_to :controller => 'podcasts', :action => 'search', :query => params[:q]
    else
      @query = params[:query]
      @podcasts = Podcast.search(@query)
    end
  end

  def new
  end

  def status
    @feed    = Feed.find_by_url(params[:feed])
    @podcast = @feed.podcast unless @feed.nil?
    
    if @feed.nil?
      render :partial => 'status_error'
    elsif @feed.parsed? && podcast_created_just_now_by_user?(@podcast)
      render :partial => 'status_added'
    elsif @feed.parsed?
      render :partial => 'status_conflict'
    elsif @feed.failed?
      render :partial => 'status_failed'
    elsif @feed.pending? or @feed.fetched?
      render :partial => 'status_loading'
    else
      render :partial => 'status_error'
    end
  end

  def cover
    @podcast = Podcast.find_by_clean_url(params[:podcast]) or raise ActiveRecord::RecordNotFound
  end

  def create
    @podcast = Podcast.create(:user => current_user)
    @podcast.feed = Feed.new(params[:feed].keep_keys([:url]))

    if current_user.nil?
      session.data[:podcasts] ||= []
      session.data[:podcasts] << @podcast.id
    end

    render :nothing => true
  end

  def update
    raise ActiveRecord::RecordNotFound if params[:podcast].nil?
    @podcast = Podcast.find_by_clean_url(params[:podcast]) or raise ActiveRecord::RecordNotFound
    authorize_write @podcast

    @podcast.attributes = params[:podcast_attr].keep_keys([:custom_title, :itunes_link])

    if @podcast.save
      flash[:notice] = 'Podcast was successfully updated.'
      redirect_to(@podcast)
    else
      render :action => "edit"
    end
  end

  def destroy
    @podcast = Podcast.find(params[:id])
    authorize_write @podcast

    @podcast.destroy

    redirect_to(podcasts_url)
  end

  protected
  
    def podcast_in_session?(podcast)
      (session.data[:podcasts] and session.data[:podcasts].include?(podcast.id))
    end
    
    def podcast_created_by_user?(podcast)
      podcast_in_session?(podcast) or podcast.writable_by?(current_user)
    end

    def podcast_created_just_now_by_user?(podcast)
      podcast_created_by_user?(podcast) && podcast.just_created?
    end
end
