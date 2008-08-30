# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def time_to_words(time)
    if time < 1.minute then
      return "#{time} sec"
    elsif time < 10.minutes  then
      return "#{(time / 1.minute)} min #{(time % 1.minute)} sec"
    elsif time < 1.hour  then
      return "#{(time / 1.minute)} min"
    elsif time < 1.day then
      return "#{(time / 1.hour)} hr #{(time % 1.hour / 1.minute)} min"
    elsif time < 7.days then
      return "#{(time / 1.day)} day #{(time % 1.day / 1.hour)} hr"
    else # more than 7 days
      return "#{(time / 1.day)} day"
    end
  end

  def link_to_profile(user)
    link_to "<span>#{h(user.login)}</span>", user_url(user), :class => 'icon user'
  end

  def link_to_thing(thing)
    link_to "#{image_tag(thing.logo.url(:icon))} <span>#{h(thing.title)}</span>", polymorphic_url(thing), :class => 'inline_icon'
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
    pretty_time_array.join(" ")
  end
end
