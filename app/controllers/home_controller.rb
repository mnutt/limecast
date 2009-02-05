class HomeController < ApplicationController
  def home
    @podcasts = Podcast.parsed.sorted
    @podcast = @podcasts.first
  end
  
  

  def stats
    @dates, @user_stats, @podcast_stats = [], [], []

    date = Time.now
    6.times do |i|
      @dates         << date.to_date
      @user_stats    << User.older_than(date).count
      @podcast_stats << Podcast.older_than(date).count

      date = date.last_month.beginning_of_month
    end
  end


  def icons
  end
end
