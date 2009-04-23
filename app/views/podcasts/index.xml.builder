xml.instruct! :xml, :version => '1.0', :encoding => 'UTF-8'

xml.podcasts do
  @podcasts.each do |podcast|
    xml.podcast do
      xml.title h(podcast.title)
      xml.primary_feed :url => podcast.primary_feed.url do
        xml.newest_episode :url => podcast.most_recent_source.url, :size => podcast.most_recent_source.size, :published_at => podcast.most_recent_source.episode.published_at.to_s(:rfc822) if podcast.most_recent_source
      end
      xml.logo :url => "http://limecast.com#{podcast.logo.url}"
      xml.description h(podcast.description)
      xml.updated_at podcast.updated_at.to_s(:rfc822)
      xml.update_interval "NOT IMPLEMENTED"
    end
  end
end