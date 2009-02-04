class PodcastsController < ApplicationController
  before_filter :login_required, :only => [:edit, :update, :destroy]
  before_filter :add_user_to_tag_string, :only => [:create, :update]

  def index
    @podcasts = Podcast.parsed.sorted
  end

  def recs
    @podcast = Podcast.find_by_clean_url(params[:podcast])
  end

  def show
    @podcast = Podcast.find_by_clean_url(params[:podcast])
    raise ActiveRecord::RecordNotFound if @podcast.nil? || params[:podcast].nil?

    @feeds    = @podcast.feeds.all
    @episodes = @podcast.episodes.
      paginate(:order => "published_at DESC", :page => (params[:page] || 1), :per_page => params[:limit] || 5)

    @reviews = @podcast.reviews
    @review  = Review.new(:episode => @podcast.episodes.newest.first)
  end

  def info
    @podcast = Podcast.find_by_clean_url(params[:podcast])
    render :layout => "info"
  end

  def search
    if params[:q]
      redirect_to :controller => 'podcasts', :action => 'search', :query => params[:q]
    else
      @query = params[:query]
      @podcasts = Podcast.search(@query)
    end
  end

  def cover
    @podcast = Podcast.find_by_clean_url(params[:podcast]) or raise ActiveRecord::RecordNotFound
    @feeds   = @podcast.feeds.all
  end

  def new
  end

  def create
    @feed = Feed.create(:url => params[:feed][:url], :finder => current_user)

    if current_user.nil?
      session.data[:feeds] ||= []
      session.data[:feeds] << @feed.id
    end

    render :nothing => true
  end


  def update
    logger.info "got here"
    raise ActiveRecord::RecordNotFound if params[:podcast].nil?
    logger.info "got here"
    @podcast = Podcast.find_by_clean_url(params[:podcast]) or raise ActiveRecord::RecordNotFound
    logger.info "got here"
    authorize_write @podcast
    logger.info "got here"

    @podcast.attributes = params[:podcast_attr].keep_keys([:tag_string, :custom_title, :primary_feed_id])
    logger.info "got here"

    respond_to do |format|
      if @podcast.save
        format.html do
          flash[:notice] = 'Podcast was successfully updated.'
          redirect_to(@podcast)
        end
        format.js { render :text => render_to_string(:partial => 'podcasts/form') }
      else
        format.html { render :action => "edit" }
        format.js { head(:failure) }
      end
    end
  end

  def favorite
    raise ActiveRecord::RecordNotFound if params[:podcast].nil?
    @podcast = Podcast.find_by_clean_url(params[:podcast]) or raise ActiveRecord::RecordNotFound

    if current_user
      @favorite = Favorite.find_or_initialize_by_podcast_id_and_user_id(@podcast.id, current_user.id)
      @favorite.new_record? ? @favorite.save : @favorite.destroy
    else
      session[:favorite] = @podcast.id
    end

    respond_to do |format|
      if @favorite
        format.html { redirect_to :back }
        format.js { render :json => {:logged_in => true} }
      else
        format.js { render :json => {:logged_in => false, :message => "Sign up or sign in to save your favorite:"} }
      end
    end

  end

  def destroy
    @podcast = Podcast.find(params[:id])
    authorize_write @podcast

    @podcast.destroy

    redirect_to(podcasts_url)
  end
  
  protected
  def add_user_to_tag_string
    if params[:podcast_attr] && params[:podcast_attr][:tag_string] && current_user
      params[:podcast_attr][:tag_string] = [params[:podcast_attr][:tag_string], current_user]
    end
  end
end
