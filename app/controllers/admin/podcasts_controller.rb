class Admin::PodcastsController < AdminController
  # GET /admin_podcasts
  # GET /admin_podcasts.xml
  def index
    @podcasts = Podcast.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @podcasts }
    end
  end

  # GET /admin_podcasts/1
  # GET /admin_podcasts/1.xml
  def show
    @podcast = Podcast.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @podcast }
    end
  end

  # GET /admin_podcasts/new
  # GET /admin_podcasts/new.xml
  def new
    @podcast = Podcast.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @podcast }
    end
  end

  # GET /admin_podcasts/1/edit
  def edit
    @podcast = Podcast.find_by_clean_title(params[:id])
  end

  # POST /admin_podcasts
  # POST /admin_podcasts.xml
  def create
    @podcast = Podcast.new(params[:podcast_slug])

    respond_to do |format|
      if @podcast.save
        flash[:notice] = 'Podcast was successfully created.'
        format.html { redirect_to(@podcast) }
        format.xml  { render :xml => @podcast, :status => :created, :location => @podcast }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @podcast.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /admin_podcasts/1
  # PUT /admin_podcasts/1.xml
  def update
    @podcast = Podcast.find(params[:id])
    @podcast.attributes = params[:podcast_slug]

    respond_to do |format|
      if @podcast.save
        flash[:notice] = 'Podcast was successfully updated.'
        format.html { redirect_to(admin_podcast_url(@podcast)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @podcast.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /admin_podcasts/1
  # DELETE /admin_podcasts/1.xml
  def destroy
    @podcast = Podcast.find(params[:id])
    @podcast.destroy

    respond_to do |format|
      format.html { redirect_to(admin_podcasts_url) }
      format.xml  { head :ok }
    end
  end
end
