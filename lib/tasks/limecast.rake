require 'app/models/podcast'
namespace :limecast do
  desc "update all podcast episodes"
  task :update do
    Podcast.find(:all).each do |podcast|
      podcast.retrieve_episodes_from_feed
    end
  end

  desc "generate encryption key"
  task :generate_encryption_key do
    `test ! -f #{RAILS_ROOT}/private/encryption_key.txt || cp #{RAILS_ROOT}/private/encryption_key.txt #{RAILS_ROOT}/private/encryption_key.txt.1`
    require 'openssl'
    encryption_key = [ OpenSSL::Random.random_bytes(60) ].pack('m*')
    File.open("#{RAILS_ROOT}/private/encryption_key.txt", 'w') do |f|
      f.write(encryption_key)
    end
  end
  
  desc "update all user scores"
  task :update_user_scores do
    User.all.each do |user|
      print "Updating score for user ##{user.id}... "
      user.calculate_score!
      puts user.score
    end
  end
  
  desc "create a statistic record for today"
  task :create_statistic do
    # Find all podcasts that are on first page of google results
    podcasts_on_google_first_page_count = Podcast.all.select { |p|
      puts "Getting Google ranking for '#{p.title}' (##{p.id})"
      search = GoogleSearchResult.new("#{p.primary_feed.title.blank? ? p.title : p.primary_feed.title}")
      search.rank('limecast.com')
    }.size

    stat = Statistic.create({
      :podcasts_count                      => Podcast.all.size,
      :podcasts_found_by_admins_count      => Podcast.found_by_admin.size,
      :podcasts_found_by_nonadmins_count   => Podcast.found_by_nonadmin.size,
      :feeds_count                         => Feed.all.size,
      :feeds_found_by_admins_count         => Feed.found_by_admin.all.size, 
      :feeds_found_by_nonadmins_count      => Feed.found_by_nonadmin.all.size, 
      :users_count                         => User.all.size,
      :users_confirmed_count               => User.confirmed.all.size,
      :users_unconfirmed_count             => User.unconfirmed.all.size,
      :users_passive_count                 => User.passive.all.size,
      :users_admins_count                  => User.admins.all.size,
      :users_nonadmins_count               => User.nonadmins.size,
      :users_makers_count                  => User.makers.nonadmins.all.size,
      :reviews_by_admins_count             => Review.claimed.by_admin.all.size,
      :reviews_by_nonadmins_count          => Review.claimed.by_nonadmin.all.size,
      :reviews_count                       => Review.all.size,
      :feeds_from_trackers_count           => Feed.from_limetracker.all.size,
      :podcasts_with_buttons_count         => Podcast.find_all_by_button_installed(true).size,
      :podcasts_on_google_first_page_count => podcasts_on_google_first_page_count
    })
    
  end
end
