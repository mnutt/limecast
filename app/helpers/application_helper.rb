# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def javascript_include(*scripts)
    @javascript_includes ||= []
    @javascript_includes << scripts
  end

  def time_to_words(time, abbr=true)
    time.to_i.to_duration.to_s(abbr)
  end

  def link_to_profile(user)
    link_text = image_tag("icons/user_#{user.rank(:include_admin => logged_in?)}.png", :class => "inline_icon")
    link_text += h(user.login)
    link_text += " (#{user.score})" unless user.podcaster?

    link_to "<span class=\"searched\">#{link_text}</span>", user_url(user),
    :title => "#{user.rank.capitalize} User"
  end

  def link_to_podcast(podcast)
    link_to "#{image_tag(podcast.logo.url(:icon), :class => 'inline_icon')}<span class=\"searched\">#{h(podcast.custom_title)}</span>", podcast_url(podcast)
  end

  def link_to_episode(episode)
    link_to "#{image_tag(episode.podcast.logo.url(:icon), :class => 'inline_icon')} <span class=\"searched\">#{h(episode.podcast.custom_title)} &mdash; #{h(episode.date_title)}</span>", episode_url(episode.podcast, episode), :class => 'inline_icon'
  end

  def link_to_with_icon(title, icon, url, options={})
    link_to("" + image_tag("icons/#{icon.to_s}.png", :class => "inline_icon") + title, url, options)
  end

  def relative_time(date, abbr=true)
    time_ago = Time.now - date
    time_to_words(time_ago, abbr) + " ago"
  end

  def unescape_entities(html)
    return nil if html.nil?
    unescaped_html = html
    unescaped_html.gsub!(/&#x26;/, "&amp;")
    unescaped_html.gsub!(/&#38;/, "&amp;")
    substitute_numerical_entities = Proc.new do |s|
      m = $1
      m = "0#{m}" if m[0] == ?x
      [Integer(m)].pack('U*')
    end
    unescaped_html.gsub!(/&#0*((?:\d+)|(?:x[a-f0-9]+));/, &substitute_numerical_entities)
    unescaped_html = CGI.unescapeHTML(unescaped_html)
    unescaped_html.gsub!(/&apos;/, "'")
    unescaped_html.gsub!(/&quot;/, "\"")

    # Replace CDATA junk
    unescaped_html.gsub!(/\<\!\[CDATA\[/, '')
    unescaped_html.gsub!(/\]\]\>/, '')
    return unescaped_html
  end

  def sanitize_summary(html)
    sanitize unescape_entities(html), :tags => %w(a b i ul li), :attributes => %w(href title)
  end

  def sanitize_condensed_summary(html)
    html = unescape_entities(html)

    # Replace paragraph tags with paragraph symbols
    html.gsub!(/<[Pp][^>]*>(.*?)\<\/[Pp]\>/, '\1 &#182; ')

    sanitize html, :tags => %w(a b i), :attributes => %w(href title)
  end

  def super_button_delivery(item)
    label = item.class == Source ? item.file_name : item.format

    if item.class == Feed
      in_parens = [item.apparent_format, item.formatted_bitrate].compact
    else item.class == Source
      label = item.format if label.length > 12
      bitrate = item.feed.formatted_bitrate if item.feed
      file_size = item.size.to_file_size.to_s

      in_parens = [bitrate, file_size].compact
    end

    in_parens = unless in_parens.empty?
      "(#{in_parens.compact.join(', ')})"
    end

    [label, in_parens].join(" ")
  end

  def smart_truncate(string, length)
    return string if string.length <= length
    string[0..(length/2)] + "..." + string[-(length/2)..-1]
  end

  def format_with_paragraph_entity(text)
    text.strip.gsub(/\r\n?/, "\n").gsub(/\n+/, "&#182;")
  end

end
