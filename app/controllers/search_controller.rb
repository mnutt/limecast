class SearchController < ApplicationController
  def index
    @users    = User.search(params[:query])
    @podcasts = Podcast.search(params[:query])
    @episodes = Episode.search(params[:query])
    @comments = Comment.search(params[:query])
  end
end
