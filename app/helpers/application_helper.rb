# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def time_to_words(time)
    time.to_duration
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
end
