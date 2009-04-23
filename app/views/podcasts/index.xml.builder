xml.instruct! :xml, :version => '1.0', :encoding => 'UTF-8'

xml.podcasts do
  @podcasts.each do |podcast|
    xml.podcast do
      xml.title h(podcast.title)
      xml.primary_feed :url => podcast.primary_feed.url do
        if s = podcast.most_recent_episode.sources.find_by_feed_id(podcast.primary_feed.id)
          xml.newest_episode :url => s.url, :size => s.size, :published_at => s.episode.published_at.to_s(:rfc822)
        end
      end
      xml.logo :url => "http://limecast.com#{podcast.logo.url}"
      xml.description h(podcast.description)
      xml.updated_at podcast.updated_at.to_s(:rfc822)
      xml.update_interval "NOT IMPLEMENTED"
    end
  end
end