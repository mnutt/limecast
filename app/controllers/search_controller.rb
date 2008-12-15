class SearchController < ApplicationController
  def index
    @users    = User.search(params[:q]).compact
    @podcasts = Podcast.scoped(:conditions => {:id => Podcast.search(params[:q]).compact.map(&:id)}).sorted
    @episodes = Episode.search(params[:q]).compact
    @reviews  = Review.search(params[:q]).compact
  end
end
