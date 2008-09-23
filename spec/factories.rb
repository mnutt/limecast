# Trying out factory girl. Check out the documentation here.
# http://github.com/thoughtbot/factory_girl/tree/master

Factory.define :podcast do |p|
  p.title    'Podcast'
  p.site     { Factory.next :site }
  p.feed_url { "#{Factory.next :site}/feed.xml" }

  p.clean_title { Factory.next :title }
end

Factory.define :fetched_podcast, :class => Podcast do |p|
  p.title         'Fetched Podcast'
  p.feed_content  { File.open("#{RAILS_ROOT}/spec/data/example.xml").read }
  p.state         'fetched'
  p.feed_url      "http://fetchedpodcast/feed.xml"
end

Factory.define :parsed_podcast, :class => Podcast do |p|
  p.title    'Podcast'
  p.state    'parsed'
  p.site     { Factory.next :site }
  p.feed_url "http://parsedpodcast/feed.xml" 
end

Factory.define :episode do |e|
  e.association  :podcast, :factory => :podcast
  e.summary      'This is the first episode of a show! w0000t'
  e.title        'Episode One'
  e.clean_title  '2008-Aug-1'
  e.duration     60

  e.published_at Time.parse("Aug 1, 2008")
end

Factory.sequence :login do |n|
  "tester#{n}"
end
Factory.sequence :email do |n|
  "tester#{n}@podcasts.example.com"
end
Factory.sequence :site do |n|
  "http://myp#{'o'*n}dcast.com"
end
Factory.sequence :title do |n|
  "P#{'o'*n}dcast"
end

Factory.define :user do |u|
  u.login                 { Factory.next :login }
  u.email                 { Factory.next :email }
  u.password              'password'
  u.password_confirmation 'password'
  u.salt                  'NaCl'
end

Factory.define :admin_user, :class => User do |u|
  u.login                 'admin'
  u.email                 'admin@podcasts.example.com'
  u.password              'password'
  u.password_confirmation 'password'
  u.salt                  'NaCl'

  u.admin true
end

Factory.define :comment, :class => Comment do |c|
  c.association :commenter, :factory => :user
  c.association :episode, :factory => :episode
end

