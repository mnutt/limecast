class EpisodesController < ApplicationController
  # GET /episodes
  # GET /episodes.xml
  def index
    if params[:podcast]
      @podcast = Podcast.find_by_clean_title(params[:podcast])
      @episodes = @podcast.episodes.find(:all)
    else
      @episodes = Episode.find(:all)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @episodes }
    end
  end

  # GET /episodes/1
  # GET /episodes/1.xml
  def show
    @podcast = Podcast.find_by_clean_title(params[:podcast]) or raise ActiveRecord::RecordNotFound
    @episode = @podcast.episodes.find_by_clean_title(params[:episode]) or raise ActiveRecord::RecordNotFound

    @comment = @episode.comments.build

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @episode }
    end
  end

  # DELETE /episodes/1
  # DELETE /episodes/1.xml
  def destroy
    unauthorized unless @episode.writable_by?(user)

    @episode = Episode.find(params[:id])
    @episode.destroy

    respond_to do |format|
      format.html { redirect_to(episodes_url) }
      format.xml  { head :ok }
    end
  end
end
