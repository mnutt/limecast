# Trying out factory girl. Check out the documentation here.
# http://github.com/thoughtbot/factory_girl/tree/master

Factory.define :tag do |t|
  t.name { Factory.next :tag }
end

Factory.define :tagging do |t|
  t.tag { Factory.create :tag }
  t.podcast { Factory.create :podcast }
end

Factory.define :user_tagging do |t|
  t.tagging { Factory.create :tagging }
  t.user { Factory.create :user }
end

Factory.define :queued_feed do |q|
  q.feed  { Factory.create :feed }
  q.url   { Factory.next :url }
  q.state "parsed"
end

Factory.define :feed do |f|
  f.url { "#{Factory.next :site}/feed.xml" }
  f.xml ""
  f.bitrate 64
end

Factory.define :podcast, :class => Podcast do |p|
  p.original_title { Factory.next :title }
  p.site  { Factory.next :site }
  p.feeds { [Factory.create(:feed, :content => nil)] }
  p.clean_url { Factory.next :title }
  p.owner_email { Factory.next :email }
end

Factory.define :parsed_podcast, :class => Podcast do |p|
  p.original_title { Factory.next :title }
  p.site  { Factory.next :site }
  p.feeds {|a| [Factory.create(:feed, :url => "#{a.site}/feed.xml", :content => File.open("#{RAILS_ROOT}/spec/data/example.xml").read)] }
  p.owner_email { Factory.next :email }

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
  s.xml ""
  s.size 1234567890
end

Factory.sequence :tag do |n|
  "tag#{n}"
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
Factory.sequence :url do |n|
  Factory.next(:site) + "/#{n}_feed.xml"
end

Factory.define :user do |u|
  u.login    { Factory.next :login }
  u.email    { Factory.next :email }
  u.password 'password'
  u.salt     'NaCl'
  u.state    'active'
end

Factory.define :passive_user, :class => User do |u|
  u.login    'notjoinedyet'
  u.email    'pass@podcasts.example.com'
  u.salt     'NaCl'
  u.state    'passive'

  u.admin true
end

Factory.define :pending_user, :class => User do |u|
  u.login    { Factory.next :login }
  u.email    { Factory.next :email }
  u.password 'password'
  u.salt     'NaCl'
  u.state    'pending'
  u.activation_code { Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join ) }
end

Factory.define :admin_user, :class => User do |u|
  u.login    'admin'
  u.email    'admin@podcasts.example.com'
  u.password 'password'
  u.salt     'NaCl'
  u.state    'active'

  u.admin true
end

Factory.define :review, :class => Review do |r|
  r.association :reviewer, :factory => :user
  r.association :episode, :factory => :episode

  r.title    'My first podcast review'
  r.body     'This podcast was very verbose! Loreim ipsum ftw.'
end

Factory.define :review_rating, :class => ReviewRating do |r|
  r.association :user, :factory => :user
  r.association :review, :factory => :review
  
  r.insightful true
end

Factory.define :favorite, :class => Favorite do |c|
  c.association :user, :factory => :user
  c.association :podcast, :factory => :podcast
end

