# Trying out factory girl. Check out the documentation here.
# http://github.com/thoughtbot/factory_girl/tree/master

Factory.define :podcast do |p|
  p.title    'Podcast'
  p.site     'http://podcasts.example.com'
  p.feed_url 'http://podcasts.example.com/feed.xml'
end

Factory.define :episode do |e|
  e.association :podcast, :factory => :podcast
  e.summary     'This is the first episode of a show! w0000t'
  e.title       'Episode One'
end

Factory.define :user do |u|
  u.login    'tester'
  u.email    'tester@podcasts.example.com'
  u.password 'password'
  u.salt     'NaCl'
end

Factory.define :admin_user, :class => User do |u|
  u.login    'admin'
  u.email    'admin@podcasts.example.com'
  u.password 'password'
  u.salt     'NaCl'

  u.admin true
end

Factory.define :podcast_comment, :class => Comment do |c|
  c.association :user, :factory => :user
  c.association :commentable, :factory => :podcast
end

Factory.define :episode_comment, :class => Comment do |c|
  c.association :user, :factory => :user
  c.association :commentable, :factory => :podcast
end

