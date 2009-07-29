class EpisodesController < ApplicationController
  before_filter :login_required, :only => [:favorite]

  def index
    @podcast  = Podcast.find_by_slug(params[:podcast_slug])

    @episodes = @podcast.episodes.find(:all, :include => [:podcast], :order => "published_at DESC")
    @newest_episode = @episodes.first
    @oldest_episode = @episodes.last if @episodes.size > 1
  end

  def search
    @q        = params[:q]
    @podcast  = Podcast.find_by_slug(params[:podcast_slug])
    @episodes = @podcast.episodes.search(@q, :include => [:podcast]).compact.uniq.sort_by(&:published_at)
    render :action => 'index'
  end

  def show
    @podcast = Podcast.find_by_slug(params[:podcast_slug])


    @episode = @podcast.episodes.find_by_slug(params[:episode])
    raise ActiveRecord::RecordNotFound if @episode.nil? || params[:episode].nil?

    @newer   = @episode.next_episode
    @older   = @episode.previous_episode
    @source  = @episode.sources.with_screenshot.with_preview.first

    render
  end

  def destroy
    @episode = Episode.find(params[:id])
    unauthorized unless @episode.writable_by?(current_user)

    @episode.destroy
  end
end
