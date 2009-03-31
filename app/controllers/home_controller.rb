class HomeController < ApplicationController
  def home
    @podcasts = Podcast.parsed.sorted

    @reviews = Review.claimed.all(:order => "created_at DESC")
    @review = @reviews.first

    @recent_reviews = Review.claimed.newest(2).with_episode
    @recent_episodes = Episode.newest(3)
    @popular_tags = Tag.all #(:order => "taggings_count DESC")
  end

  def stats
    @dates, @user_stats, @podcast_stats, @hd_stats, @p2p_stats, @review_stats = [], [], [], [], [], []

    date = Time.now
    6.times do |i|
      @dates         << date.to_date
      @user_stats    << User.older_than(date).count
      @podcast_stats << Podcast.older_than(date).count
      @hd_stats      << Podcast.tagged_with("hd").older_than(date).count
      @p2p_stats     << Podcast.older_than(date).count(:conditions => {:has_p2p_acceleration => true})
      @review_stats  << Review.older_than(date).count
      date = date.last_month.beginning_of_month
    end
    render :layout => 'info'
  end

  def icons
    render :layout => 'info'
  end

  def info
    @podcasts = Podcast.sorted

    if File.exist?(File.join(RAILS_ROOT, '..', '..', 'current'))
      @release = Time.parse(RAILS_ROOT.split("/").last) rescue nil
    else
      @release = "(not deployed)"
    end

    if File.exist?("#{RAILS_ROOT}/.git")
      master_info = "#{RAILS_ROOT}/.git/refs/heads/master"
      @commit = File.read(master_info) if File.exist?(master_info)
      deploy_info = "#{RAILS_ROOT}/.git/refs/heads/deploy"
      @commit = File.read(deploy_info) if File.exist?(deploy_info)
      commit_msg = "#{RAILS_ROOT}/.git/COMMIT_EDITMSG"
      @message = File.read(commit_msg) if File.exist?(commit_msg)
    end
    render :layout => 'info'
  end
end
