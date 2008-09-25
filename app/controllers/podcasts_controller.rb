class PodcastsController < ApplicationController
  before_filter :login_required, :only => [:edit, :update, :destroy]
  skip_before_filter :verify_authenticity_token, :only => :status

  def index
    @podcasts = Podcast.parsed.find(:all, :order => "title ASC")
  end

  def show
    @podcast = Podcast.find_by_clean_url(params[:podcast]) or raise ActiveRecord::RecordNotFound
    @episodes = @podcast.episodes.find(:all, :limit => 3)

    @comments = with(@podcast.episodes.newest.first) {|ep| ep.nil? ? [] : ep.comments }
    @comment  = Comment.new(:episode => @podcast.episodes.newest.first)
  end

  def search
    if params[:q]
      redirect_to :controller => 'podcasts', :action => 'search', :query => params[:q]
    else
      @query = params[:query]
      @podcasts = Podcast.search(@query, :conditions => {:state => "parsed"})
    end
  end

  def feed_info
    @podcast = Podcast.new_from_feed(params[:feed])
  rescue
    render :partial => "bad_feed"
  end

  def new
    @podcast = Podcast.new
  end

  def edit
    @podcast = Podcast.find(params[:id])
    authorize_write @podcast
  end

  def status
    @podcast = Podcast.find_by_feed_url(params[:feed])
    
    if @podcast.nil?
      render :text => "Error: podcast not found."
    elsif @podcast.state == "parsed" or @podcast.state == "failed"
      render :partial => 'podcasts/added_podcast'
    else
      render :partial => "loading"
    end
  end

  def create
    @podcast = Podcast.create!(:feed_url => params[:podcast][:feed_url], 
                               :user     => current_user)

    if current_user.nil?
      session.data[:podcasts] ||= []
      session.data[:podcasts] << @podcast.id
    end

    render :nothing => true
  end

  def update
    @podcast = Podcast.find(params[:id])
    authorize_write @podcast

    @podcast.attributes = params[:podcast]

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
end
