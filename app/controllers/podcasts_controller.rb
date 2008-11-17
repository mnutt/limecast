class PodcastsController < ApplicationController
  before_filter :login_required, :only => [:edit, :update, :destroy]

  def index
    @podcasts = Podcast.parsed.sorted
  end

  def show
    @podcast = Podcast.find_by_clean_url(params[:podcast])
    raise ActiveRecord::RecordNotFound if @podcast.nil? || params[:podcast].nil?

    @feeds    = @podcast.feeds.all
    @episodes = @podcast.episodes.find(:all, :order => "published_at DESC", :limit => 3)

    @reviews = with(@podcast.episodes.newest.first) {|ep| ep.nil? ? [] : ep.reviews }
    @review  = Review.new(:episode => @podcast.episodes.newest.first)
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
    raise ActiveRecord::RecordNotFound if params[:podcast].nil?
    @podcast = Podcast.find_by_clean_url(params[:podcast]) or raise ActiveRecord::RecordNotFound
    authorize_write @podcast

    @podcast.attributes = params[:podcast_attr].keep_keys([:custom_title])

    if @podcast.save
      flash[:notice] = 'Podcast was successfully updated.'
      redirect_to(@podcast)
    else
      render :action => "edit"
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
        format.js
      else
        format.js
      end
    end

  end

  def destroy
    @podcast = Podcast.find(params[:id])
    authorize_write @podcast

    @podcast.destroy

    redirect_to(podcasts_url)
  end
end
