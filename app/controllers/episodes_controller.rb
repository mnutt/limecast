class EpisodesController < ApplicationController
  # GET /episodes
  # GET /episodes.xml
  def index
    @episodes = Episode.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @episodes }
    end
  end

  # GET /episodes/1
  # GET /episodes/1.xml
  def show
    @episode = Episode.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @episode }
    end
  end

  # GET /episodes/new
  # GET /episodes/new.xml
  def new
    @episode = Episode.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @episode }
    end
  end

  # GET /episodes/1/edit
  def edit
    @episode = Episode.find(params[:id])
  end

  # POST /episodes
  # POST /episodes.xml
  def create
    @episode = Episode.new(params[:episode])

    respond_to do |format|
      if @episode.save
        flash[:notice] = 'Episode was successfully created.'
        format.html { redirect_to(@episode) }
        format.xml  { render :xml => @episode, :status => :created, :location => @episode }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @episode.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /episodes/1
  # PUT /episodes/1.xml
  def update
    @episode = Episode.find(params[:id])

    respond_to do |format|
      if @episode.update_attributes(params[:episode])
        flash[:notice] = 'Episode was successfully updated.'
        format.html { redirect_to(@episode) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @episode.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /episodes/1
  # DELETE /episodes/1.xml
  def destroy
    @episode = Episode.find(params[:id])
    @episode.destroy

    respond_to do |format|
      format.html { redirect_to(episodes_url) }
      format.xml  { head :ok }
    end
  end
end
