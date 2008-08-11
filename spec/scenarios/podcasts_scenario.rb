class PodcastsScenario < Scenario::Base
  
  def load
    create_record(:podcast, :default,
                  :title => "Default Podcast",
                  :site => "http://testsite.com",
                  :feed => "http://testsite.com/feed.xml",
                  :description => "Default description.",
                  :email => "default@owner.com",
                  :owner_name => "Default Owner",
                  :language => "en-us")
  end
end
