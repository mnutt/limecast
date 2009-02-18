class HomeController < ApplicationController
  def home
    @podcasts = Podcast.parsed.sorted
    
    @reviews = Review.all(:order => "created_at DESC")
    @review = @reviews.first

    @recent_reviews = Review.newest(2).with_episode
    @recent_episodes = Episode.newest(3)
    @popular_tags = Tag.all #(:order => "taggings_count DESC")
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
    render :layout => false
  end

  def info
    @podcasts = Podcast.all
    
    if File.exist?(File.join(RAILS_ROOT, '..', '..', 'current'))
      @release = Time.parse(RAILS_ROOT.split("/").last) rescue nil
    else
      @release = "(not deployed)"
    end

    if File.exist?("#{RAILS_ROOT}/.git")
      master_info = "#{RAILS_ROOT}/.git/refs/heads/master"
      @commit = File.read(master_info) if File.exist?(master_info)
      commit_msg = "#{RAILS_ROOT}/.git/COMMIT_EDITMSG"
      @message = File.read(commit_msg) if File.exist?(commit_msg)
    end
    render :layout => false
  end
end
