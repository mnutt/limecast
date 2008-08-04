class PodcastsController < ApplicationController
  before_filter :login_required, :only => [:new, :edit, :create, :update, :destroy]
  # GET /podcasts
  # GET /podcasts.xml
  def index
    @podcasts = Podcast.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @podcasts }
    end
  end

  # GET /podcasts/1
  # GET /podcasts/1.xml
  def show
    @podcast = Podcast.find_by_clean_title(params[:podcast])
    @episodes = @podcast.episodes.find(:all, :limit => 3)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @podcast }
    end
  end

  def feed_info
    @podcast = Podcast.new_from_feed(params[:feed])
  rescue
    render :partial => "bad_feed"
  end

  # GET /podcasts/new
  # GET /podcasts/new.xml
  def new
    login_required

    @new_podcast = Podcast.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @podcast }
    end
  end

  # GET /podcasts/1/edit
  def edit
    @podcast = Podcast.find(params[:id])
    authorize_write @podcast
  end

  # POST /podcasts
  # POST /podcasts.xml
  def create
    login_required

    @podcast = Podcast.new_from_feed(params[:podcast][:feed])
    @podcast.user = current_user
    @podcast.owner = current_user if @podcast.email == current_user.email

    respond_to do |format|
      format.html do
        if @podcast.save
          @new_podcast = Podcast.new
        else
          @new_podcast = @podcast
        end
        render :action => "new"
      end
    end
  end

  # PUT /podcasts/1
  # PUT /podcasts/1.xml
  def update
    @podcast = Podcast.find(params[:id])
    authorize_write @podcast

    @podcast.attributes = params[:podcast]
    respond_to do |format|
      if @podcast.save
        flash[:notice] = 'Podcast was successfully updated.'
        format.html { redirect_to(@podcast) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @podcast.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /podcasts/1
  # DELETE /podcasts/1.xml
  def destroy
    @podcast = Podcast.find(params[:id])
    authorize_write @podcast

    @podcast.destroy

    respond_to do |format|
      format.html { redirect_to(podcasts_url) }
      format.xml  { head :ok }
    end
  end
end
