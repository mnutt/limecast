require 'app/models/podcast'
namespace :limecast do
  desc "update all podcast episodes"
  task :update do
    Podcast.find(:all).each do |podcast|
      podcast.retrieve_episodes_from_feed
    end
  end
end
