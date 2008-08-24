class HomeController < ApplicationController
  def home
    @podcasts = Podcast.find(:all, :limit => 10, :order => "created_at DESC")
  end
end
