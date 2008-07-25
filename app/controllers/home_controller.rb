class HomeController < ApplicationController
  def home
    # @podcasts = Podcast.find(:all, :limit => 20, :order => "created_at DESC")
    # @episodes = Episode.find(:all, :limit => 20, :order => "published_at DESC")
    redirect_to '/all'
  end
end
