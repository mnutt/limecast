p = Podcast.create(:feed_url => "http://example.com/feed.xml", :feed_content => File.open("#{RAILS_ROOT}/spec/data/example.xml").read); p.state = "fetched"; p.parse!; p.destroy
