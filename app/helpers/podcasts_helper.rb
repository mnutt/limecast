module PodcastsHelper
  def rss_link(feed)
    %{<link rel="alternate" type="application/rss+xml" title="#{feed.formatted_bitrate} #{feed.apparent_format}" href="#{feed.url}" />}
  end

  def paginate_podcasts(podcasts)
    will_paginate podcasts,
      :previous_label => '<img src="../imgs/icons/left-arrow.gif" title="Previous page" />',
      :next_label     => '<img src="../imgs/icons/right-arrow.gif" title="Next page" />',
      :inner_window   => 1,
      :outer_window   => 1
  end

  def link_to_podcast_home(podcast)
    link_to h(podcast.clean_site), h(podcast.site)
  end

  def cover_art(podcast, size = :small)
    if podcast.logo?
      podcast.logo.url(size)
    else
      "/imgs/no_cover.png"
    end
  end

  def display_cover_art(podcast, opts = {})
    size = opts.delete(:size) || :small

    defaults = { :alt => "#{podcast.title} cover art", :class => "logo" }.merge(opts)

    image_tag(cover_art(podcast, size))
  end
end
