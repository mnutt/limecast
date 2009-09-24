# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def google_ads
    %{<div class="googleads">#{@ads}</div>}
  end

  # Renders a UL tag, where each LI has an A. The anchors have a +rel+ attribute
  # that can be used by JS.
  #
  # Example:
  #   * dropdown ["Most recent", "First to last"], 1, {} -%>
  #
  # NOTE: Not in use by current design
  #
  def dropdown(links, selected_index, options = {})
    selected_index ||= 0
    label = options.delete(:label)
    options[:class] = "dropdown #{options[:class]}"

    focuser = content_tag :span, links[selected_index], :class => 'focuser'

    links = links.zip((0..links.size).to_a).map do |link, i|
      "<li#{' class="selected"' if i == selected_index}>#{link}</li>"
    end

    ul = "<ul>#{links}</ul>"
    content_tag :div, "#{label}#{focuser}#{rounded_corner_tag(ul, :class => 'dropdown_wrap')}", {:class => options[:class]}.merge(options)
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

  # All the text on a single line and no links. 
  def line_description(html)
    HTML::WhiteListSanitizer.new.sanitize(html, :tags => %w(), :attributes => %w()).to_s.strip
  end

  # Allows only links and separate paragraphs.
  def page_description(html)
    HTML::WhiteListSanitizer.new.sanitize(html, :tags => %w(a br p), :attributes => %w(href)).to_s.strip
  end

  def link_to_profile(user)
    link_text = h(user.login)
    link_text += "" unless user.podcaster?

    link_to "<span>#{link_text}</span>", user_url(user),
    :title => "#{user.rank.capitalize} User"
  end

  def link_to_searched_podcast(podcast)
    link_to "<mark>#{h(podcast.title)}</mark>", podcast_url(podcast)
  end

  def link_to_episode_date(episode)
    link_to "#{image_tag(episode.podcast.logo.url(:icon), :class => 'inline_icon')}#{h(episode.date_title)}", episode_url(episode.podcast, episode), :class => 'inline_icon'
  end

  def link_to_with_icon(title, icon, url, options={})
    link_to(title.to_s, url, options)
  end

  def messages_for(obj, col)
    "<p style=\"padding: 1px; color: black; display: inline; border: solid 4px lemonchiffon; background: white;\" class=\"message\">
      #{obj.messages[col.to_s].join(', ')}
    </p>" unless obj.messages[col.to_s].blank? || obj.messages[col.to_s].empty?
  end

  def errors_for(obj, col)
    "<p style=\"padding: 1px; color: red; display: inline; border: solid 2px pink; background: white;\" class=\"error\">
      #{obj.errors.on(col).is_a?(String) ? obj.errors.on(col) : obj.errors.on(col).to_sentence}
    </p>" unless obj.errors.on(col).blank?
  end

  def span_with_icon(title, icon, options={})
    content_tag(:span, image_tag("icons/#{icon.to_s}.png", :class => "inline_icon") + " #{title}" , options)
  end
  
  # 2009 Jan 1 1:12p (2h 5m ago)
  def relative_time(date, abbr=true, with_time=true, with_parens=true)
    return nil unless date.is_a?(Time) or date.is_a?(DateTime) or date.is_a?(Date)
    time_ago = Time.now - date
    datestamp = date.in_time_zone('Eastern Time (US & Canada)').strftime("%Y %b %d").gsub(/(^|\s)0([1-9])/,'\1\2')
    timestamp = date.in_time_zone('Eastern Time (US & Canada)').strftime("%I:%m%p").gsub(/(^|\s)0([1-9])/,'\1\2').gsub(/AM|PM/) {|m| m.first.downcase}
    ago = with_parens ? "(#{time_to_words(time_ago, abbr)} ago)" : "#{time_to_words(time_ago, abbr)} ago"
    "#{datestamp}#{' '+timestamp if with_time} #{ago}"
  end

  def unescape_entities(html, leave_dirty = false)
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

    if leave_dirty
      unescaped_html
    else
      sanitize unescaped_html
    end
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
  
  # Currently used to sanitize for the info pages: "letting all but the most dangerous HTML through."
  def sanitize_lightly(html)
    sanitize html, :tags => %w(strong em b i p code pre tt samp kbd var sub 
      sup dfn cite big small address hr br div span h1 h2 h3 h4 h5 h6 ul ol li dt dd abbr 
      acronym a img blockquote del ins)
  end

  # The 'search_term_context.js' script was stripping out results beyond the ones 
  # that it found (ie "Abracadabra" -> "Abrcdbr"), so this uses Rails instead to do the job.
  def search_excerpt(text, query='')
    text      = strip_tags(format_with_paragraph_entity(text))
    escaped   = unescape_entities(text)
    excerpted = excerpt(escaped, query.split.first, :radius => 120)
    highlight(excerpted, query.split, :highlighter => '<mark>\1</mark>')
  end

  def smart_truncate(string, length)
    return string if string.length <= length
    string[0..(length/2)] + "..." + string[-(length/2)..-1]
  end

  def truncate_split(string, length)
    indexOfFirstSpaceAfterLength = string[(length+1)..-1].index(" ")
    first = string[0..(length+indexOfFirstSpaceAfterLength)]
    last  = string[(length+indexOfFirstSpaceAfterLength+2)..-1]

    [first, last]

  rescue
    [string, nil]
  end

  def truncated_text(string, length)
    pieces = (length < 0) ? [string,nil] : truncate_split(string, length)

    str = pieces.first
    unless pieces.last.nil?
      str << %{<span class="truncated less">&hellip;</span>\n<span class="truncated more">#{pieces.last}</span>\n<a href="#" class="truncated">more</a>}
    end

    str
  end

  def format_with_paragraph_entity(text)
    text.strip.gsub(/\r\n?/, "\n").gsub(/\n+/, "&#182;")
  end

  # Ex: rounded_corner_tag('inside text', :class => "whatever")
  # Ex: rounded_corner_tag(:class => "whatever") do
  #       inside block text
  #     end
  def rounded_corner_tag(text_or_options = nil, options = nil, &block)
    options = text_or_options if text_or_options.is_a?(Hash)
    options ||= {}
    options[:class] = options[:class].blank? ? "rounded_corners" : "#{options[:class]} rounded_corners"

    wrap = <<-ROUNDED
    <div class="bt"><div></div></div><div class="i1"><div class="i2"><div class="i3">%s</div></div></div><div class="bb"><div></div></div>
    ROUNDED

    if block_given?
      rounded_content = content_tag(:div, (wrap % capture(&block)), options)
      block_called_from_erb?(block) ? concat(rounded_content) : rounded_content
    else
      content_tag(:div, (wrap % text_or_options), options)
    end
  end


  def limecast_form_for record_or_name_or_array, *args, &proc #@podcast, } do |podcast_form|
    options = args.extract_options!
    (options[:html] ||= {})
    options[:html][:class] = "#{options[:html][:class]} limecast_form clear"
    options[:html][:style] = "display: none; #{options[:html][:style]}" unless options[:show]

    form_for(record_or_name_or_array, *(args << options)) do |form_builder|
      concat('<div class="top"><!-- //--></div>')
      concat('<div class="middle">')
      yield form_builder
      concat('</div>')
      concat('<div class="bottom controls">')
      concat form_builder.submit("Save", :class => "button")
      concat form_builder.submit("Cancel", :class => "button cancel")
      concat('</div>')
    end
  end

  # Should we show this object's edit form?
  def editing?(obj)
    # puts "\nobj errors are #{obj.errors.inspect}\n"
    # logger.info "\napphelper:207: #{!obj.valid?} || #{!obj.messages.empty?} || #{!flash[:has_messages].blank?}\n"
    # logger.info "\nthe flash is #{flash.inspect}\n"
    # logger.info "\nthe podcast messages are #{@podcast.messages.inspect}\n" if @podcast
    !obj.valid? || !flash[:has_messages].blank?
  end

  def running_text
    "<span style=\"color: green; font-size: 16px;\">&#8226;</span>"
  end

  def not_running_text
    "<span style=\"color: red; font-size: 16px;\">&#8226;</span>"
  end

  # Question mark on info pages, #non_blank also does #h
  def non_blank(text=nil, escape=true, &block)
    if block
      begin
        block.call
      rescue
        blankness
      end
    else
      (text.blank? || text == 0) ? blankness : (escape ? h(text) : text)
    end
  end
  
  def blankness
    "<span class='unknown'>?</span>"
  end

  def info_user_link(user)
    link_to(h(user.login), info_user_url(user))
  rescue
    non_blank ""
  end

  def info_source_link(source, ability=true)
    [link_to(non_blank(source.formatted_bitrate) + " " + non_blank(source.extension), info_source_url(source.podcast, source.episode, source.id)), (content_tag(:sup, ability ? source.ability : nil))].join
  end

  # Takes an array of integers called +data_points+ and returns a URL to Google's Chart API
  # that returns a 25x25 image graph
  def sparkline_link(data_points=[])
    "http://chart.apis.google.com/chart?cht=ls&chd=t:#{data_points.map(&:to_i).join(',')}&chs=20x20&chco=4D89F9&chm=B,76A4FB,0,0,0"
  end

  # Takes an array of integers called +data_points+ and returns an image from Google's Chart API
  # that returns a 25x25 image graph
  def sparkline(data_points=[])
    image_tag sparkline_link(data_points)
  end

  def custom_button(text="", options={})
    content_tag :button, content_tag(:span, text), options.merge(:type => "submit")
    # "<button type=\"submit\"><span>#{text}</span></button>"
  end

  def callout(text)
    "<div class=\"callout\"><ul><li>#{text}</li></ul></div>"
  end
end
