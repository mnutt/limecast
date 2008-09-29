class EpisodesController < ApplicationController
  # GET /episodes
  # GET /episodes.xml
  def index
    if params[:podcast]
      @podcast = Podcast.find_by_clean_url(params[:podcast])
      @episodes = @podcast.episodes.find(:all, :order => "published_at DESC")
    else
      @episodes = Episode.find(:all)
    end
  end

  # GET /episodes/1
  # GET /episodes/1.xml
  def show
    @podcast = Podcast.find_by_clean_url(params[:podcast]) or raise ActiveRecord::RecordNotFound
    @episode = @podcast.episodes.find_by_clean_url(params[:episode]) or raise ActiveRecord::RecordNotFound

    @comment = Comment.new(:episode => @episode)
  end

  # DELETE /episodes/1
  # DELETE /episodes/1.xml
  def destroy
    unauthorized unless @episode.writable_by?(current_user)

    @episode = Episode.find(params[:id])
    @episode.destroy
  end
end
