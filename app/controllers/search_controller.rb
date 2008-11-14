class SearchController < ApplicationController
  def index
    @users    = User.search(params[:q])
    @podcasts = Podcast.scoped(:conditions => {:id => Podcast.search(params[:q]).map(&:id)}).sorted
    @episodes = Episode.search(params[:q])
    @reviews  = Review.search(params[:q])
  end
end
