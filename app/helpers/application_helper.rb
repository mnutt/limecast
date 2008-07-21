# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def date_to_words(date)
    if date < 10 then
      return 'just a moment'
    elsif date < 40  then
      return 'less than ' + (date * 1.5).to_i.to_s.slice(0,1) + '0 seconds'
    elsif date < 60 then
      return 'less than a minute'
    elsif date < 60 * 1.3  then
      return "1 minute"
    elsif date < 60 * 50  then
      return "#{(date / 60).to_i} minutes"
    elsif date < 60  * 60  * 1.4 then
      return 'about 1 hour'
    elsif date < 60  * 60 * (24 / 1.02) then
      return "about #{(date / 60 / 60 * 1.02).to_i} hours"
    else
      return "about #{(date / 60 / 60 * 1.02 / 24).to_i} days"
    end
  end

  def link_to_profile(user)
    link_to user_url(user) do
      link = image_tag('icons/user.png')
      link << h(user.login)
      link << " (#{user.score})" unless user.podcaster?
    end
  end

  def link_user_with_icon(user)
    link_to("#{image_tag('/images/icons/user.png')} #{h(user.login)}", user_url(user))
  end

  def link_with_icon(thing)
    link_to("#{image_tag(thing.logo.url(:icon))} #{h(thing.title)}", polymorphic_url(thing))
  end

  def relative_time(date)
    time_ago = Time.now - date
    date_to_words(time_ago) + " ago"
  end

  def pretty_duration(seconds)
    seconds = seconds.to_i
    pretty_time_array = []
    if seconds > 60*60
      pretty_time_array << (seconds / (60 * 60)).to_s + " hr"
      seconds = seconds % (60 * 60)
    elsif seconds > 60
      pretty_time_array << (seconds / 60).to_s + " min"
      seconds = seconds % 60
    end
    pretty_time_array << seconds.to_s + " sec"
    pretty_time_array.join(", ")
  end
end
