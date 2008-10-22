# Trying out factory girl. Check out the documentation here.
# http://github.com/thoughtbot/factory_girl/tree/master

Factory.define :feed do |f|
  f.url     { "#{Factory.next :site}/feed.xml" }
  f.content { File.open("#{RAILS_ROOT}/spec/data/example.xml").read }
  f.bitrate 64
end

Factory.define :podcast do |p|
  p.title 'Podcast'
  p.site  { Factory.next :site }
  p.feeds { [Factory.create(:feed, :content => nil)] }
  p.clean_url { Factory.next :title }
end

Factory.define :parsed_podcast, :class => Podcast do |p|
  p.title 'Podcast'
  p.site  { Factory.next :site }
  p.feeds { [Factory.create(:feed, :url => "http://parsedpodcast/feed.xml", :content => nil, :state => 'parsed')] }

  p.clean_url { Factory.next :title }
end

Factory.define :failed_podcast, :class => Podcast do |p|
  p.title 'Podcast'
  p.site  { Factory.next :site }
  p.feeds { [Factory.create(:feed, :state => 'failed')] }

  p.clean_url { Factory.next :title }
end

Factory.define :episode do |e|
  e.association :podcast, :factory => :podcast
  e.summary     'This is the first episode of a show! w0000t'
  e.title       'Episode One'
  e.clean_url   '2008-Aug-1'
  e.duration    60
  e.sources     { [Factory.create(:source)] }

  e.published_at Time.parse("Aug 1, 2008")
end

Factory.define :source do |s|
  s.url  "http://example.com/source.mpg"
  s.guid { (Time.now.to_i * rand).to_s }
  s.size 1234567890
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
  u.login    { Factory.next :login }
  u.email    { Factory.next :email }
  u.password 'password'
  u.salt     'NaCl'
  u.state    'active'
end

Factory.define :admin_user, :class => User do |u|
  u.login    'admin'
  u.email    'admin@podcasts.example.com'
  u.password 'password'
  u.salt     'NaCl'
  u.state    'active'

  u.admin true
end

Factory.define :comment, :class => Comment do |c|
  c.association :commenter, :factory => :user
  c.association :episode, :factory => :episode
end

