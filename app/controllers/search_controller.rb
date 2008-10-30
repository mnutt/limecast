class SearchController < ApplicationController
  def index
    @users    = User.search(params[:q])
    @podcasts = Podcast.search(params[:q])
    @episodes = Episode.search(params[:q])
    @comments = Comment.search(params[:q])
  end
end
