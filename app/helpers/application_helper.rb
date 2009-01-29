# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def javascript_include(*scripts)
    @javascript_includes ||= []
    @javascript_includes << scripts
  end

  def comma_separated_list_items(arr)
    delimited_items(arr) do |contents, comma|
      "<li>#{contents}#{comma}</li>\n"
    end
  end

  def delimited_items(arr, delimiter = ",")
    # :-( RIP: "<li>" + arr.zip([","] * (arr.length-1)).map(&:join).join("</li><li>") + "</li>"
    #        : a.fill((0..-2)){|i| "#{a[i]}," }.map {|i| "<li>#{i}</li>" }.join

    arr.map do |i|
      yield i, (delimiter unless i == arr.last)
    end.join
  end

  def time_to_words(time, abbr = false)
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
    link_to("" + image_tag("icons/#{icon.to_s}.png", :class => "inline_icon") + title.to_s, url, options)
  end

  def span_with_icon(title, icon, options={})
    content_tag(:span, image_tag("icons/#{icon.to_s}.png", :class => "inline_icon") + " #{title}" , options)
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
  def search_excerpt(text, query)
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

  # Renders a UL tag, where each LI has an A. The anchors have a +rel+ attribute
  # that can be used by JS.
  #
  # Example:
  #   * dropdown [["Most recent","recent"], ["First to last","oldest"]], 'oldest', {} -%>
  #
  def dropdown(links=[], selected=nil, options={})
    title = options.delete(:title)
    options[:class] = "dropdown #{options[:class]}"

    selected = (selected.nil? ? (links.first) : (links.find {|l| l.last==selected}))
#    focuser   = "<input class=\"focuser\" value=\"#{selected.first}\" readonly=\"readonly\" />"
#    focuser = label_tag :focuser, selected.first, :class => 'focuser'
    focuser = link_to selected.first, "#", :class => 'focuser'
    
    links   = case links
              when Array
                links.map { |l| 
                  is_selected = (selected==l) ? " class=\"selected\"" : ""
                  "<li#{is_selected}>#{link_to l.first, '#', :rel => l.last}</li>"
                }
              else
                []
              end.join

    content_tag :div, "#{title}#{focuser}<div class=\"dropdown_wrap\"><ul class=\"cbb\">#{links}</ul></div>", {:class => options[:class]}.merge(options)
  end
  

end
