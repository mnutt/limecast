class HomeController < ApplicationController
  def home
    @episodes = Episode.find(:all, :limit => 20, :order => "published_at DESC")
  end
end
