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

  def link_to_episode_date(episode)
    link_to "#{image_tag(episode.podcast.logo.url(:icon), :class => 'inline_icon')}#{h(episode.date_title)}", episode_url(episode.podcast, episode), :class => 'inline_icon'
  end

  def link_to_with_icon(title, icon, url, options={})
    link_to("" + image_tag("icons/#{icon.to_s}.png", :class => "inline_icon") + title.to_s, url, options)
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

    # Replace curled quotes and double-quotes
    unescaped_html.gsub!(/(“|”|&#8220;|&#8221;)/,'"')
    unescaped_html.gsub!(/(‘|’|&#8216;|&#8217;)/,"'")

    # Replace CDATA junk
    unescaped_html.gsub!(/\<\!\[CDATA\[/, '')
    unescaped_html.gsub!(/\]\]\>/, '')
    return unescaped_html
  end

  def sanitize_summary(html)
    sanitize unescape_entities(html), :tags => %w(a b i ul li), :attributes => %w(href title)
  end

  def sanitize_condensed_summary(html)
    html = unescape_entities(html.to_s)

    # Replace paragraph tags with paragraph symbols
    html.strip.gsub!(/<[Pp][^>]*>(.*?)\<\/[Pp]\>/, '\1 &#182; ')

    sanitize html, :tags => %w(a b i), :attributes => %w(href title)
  end

  # The 'search_term_context.js' script was stripping out results beyond the ones 
  # that it found (ie "Abracadabra" -> "Abrcdbr"), so this uses Rails instead to do the job.
  def search_excerpt(text, query='')
    text      = strip_tags(format_with_paragraph_entity(text))
    escaped   = unescape_entities(text)
    excerpted = excerpt(escaped, query.split.first, :radius => 50)
    highlight(excerpted, query.split, :highlighter => '<span class="search_term">\1</span>')
  end

  # Put the primary feed/source at top (if one exists)
  # TODO isn't there an easier way in Ruby to do this?
  def sorted_by_primary(feeds_or_sources=[])
    feeds_or_sources.sort_by { |f| f.primary? ? 0 : 1 }
  rescue
    feeds_or_sources
  end

  def super_button_delivery(item)
    label = item.class == Source ? item.file_name : item.format

    if item.class == Feed
      in_parens = [item.formatted_bitrate, item.apparent_format].compact
    else item.class == Source
      label = item.format if label.length > 12
      bitrate = item.feed.formatted_bitrate if item.feed
      file_size = item.size.to_file_size.to_s

      in_parens = [file_size, item.format].compact
    end

    in_parens = unless in_parens.empty?
      "(#{in_parens.compact.join(' ')})"
    end

    in_parens
  end

  def smart_truncate(string, length)
    return string if string.length <= length
    string[0..(length/2)] + "..." + string[-(length/2)..-1]
  end

  def format_with_paragraph_entity(text)
    text.strip.gsub(/\r\n?/, "\n").gsub(/\n+/, "&#182;")
  end

  def messages_for(obj, col)
    "<p style=\"padding: 1px; color: black; display: inline; border: solid 4px lemonchiffon; background: white;\" class=\"message\">
      #{obj.messages[col.to_s].join(', ')}
    </p>" unless obj.messages[col.to_s].blank? || obj.messages[col.to_s].empty?
  end

  def errors_for(obj, col)
    "<p style=\"padding: 1px; color: red; display: inline; border: solid 4px pink; background: white;\" class=\"error\">
      #{obj.errors.on(col)}
    </p>" unless obj.errors.on(col).blank?
  end
  
  def span_with_icon(title, icon, options={})
    content_tag(:span, image_tag("icons/#{icon.to_s}.png", :class => "inline_icon") + " #{title}" , options)
  end
  
  def limecast_form_for record_or_name_or_array, *args, &proc
    options = args.extract_options!
    (options[:html] ||= {})
    options[:html][:class] = "#{options[:html][:class]} limecast_form clearfix"
    options[:html][:style] = "display: none; #{options[:html][:style]}" unless options[:show]
  
    form_for(record_or_name_or_array, *(args << options)) do |form_builder|
      concat('<div class="top"><!-- //--></div>')
      concat('<div class="middle">')
      yield form_builder
      concat('</div>')
      concat('<div class="bottom controls">')
      concat form_builder.submit("Save", :class => "button")
      concat form_builder.submit("Cancel", :class => "button cancel")
      # concat link_to_with_icon("Delete", :delete, "/podcasts/#{@podcast.id}", :method => "delete", :confirm => "Are you SURE you want to delete this podcast? It will be removed from this directory!")
      concat('</div>')
    end
  end

  # Should we show this object's edit form?
  def editing?(obj)
    !obj.valid? || !obj.messages.empty?
  end

end
