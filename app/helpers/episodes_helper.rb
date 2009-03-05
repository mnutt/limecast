module EpisodesHelper
  def scaled_resolution(res)
    scale_to_width = 460

    height = ((scale_to_width / res[:width].to_f) * res[:height]) rescue nil

    { :height => height || 362, :width => scale_to_width }
  end

  def link_to_episode(ep)
    link_to ep.title, episode_url(:podcast_slug => ep.podcast, :episode => ep)
  end
end
