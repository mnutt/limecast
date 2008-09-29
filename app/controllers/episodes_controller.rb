class EpisodesController < ApplicationController
  def index
    @podcast = Podcast.find_by_clean_url(params[:podcast])
    @episodes = @podcast.episodes.find(:all, :order => "published_at DESC")
  end

  def show
    @podcast = Podcast.find_by_clean_url(params[:podcast]) or raise ActiveRecord::RecordNotFound
    @episode = @podcast.episodes.find_by_clean_url(params[:episode]) or raise ActiveRecord::RecordNotFound

    @comment = Comment.new(:episode => @episode)
  end

  def destroy
    unauthorized unless @episode.writable_by?(current_user)

    @episode = Episode.find(params[:id])
    @episode.destroy
  end
end
