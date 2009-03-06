module EpisodesHelper
  def scaled_resolution(res)
    scale_to_width = 460

    height = ((scale_to_width / res[:width].to_f) * res[:height]) rescue nil

    { :height => height || 362, :width => scale_to_width }
  end

  def link_to_episode(ep)
    link_to ep.title, episode_url(:podcast_slug => ep.podcast, :episode => ep)
  end

  def display_episode_screenshot(ep)
    if ep.sources.first && ep.sources.first.screenshot?
      image_tag(ep.sources.first.screenshot(:square).to_s, :height => 55, :width => 55)
    else
      image_tag(cover_art(ep.podcast, :square), :height => 55, :width => 55)
    end
  end
end
