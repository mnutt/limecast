ActionController::Routing::Routes.draw do |map|
  # Resources
  map.resources :categories
  map.resources :reviews
#  map.resources :podcasts
  map.resources :episodes
  map.resources :feeds
  
  map.admin '/admin', :controller => 'admin', :action => 'index'
  map.namespace :admin do |admin|
    admin.resources :podcasts
    admin.resources :episodes
    admin.resources :tags, :member => { :merge => :any }
    admin.resources :users

	  admin.approve_podcast '/podcast/:podcast_slug/approve', :action => "approve", :controller => "podcasts"
  end

  map.resources :users
  map.resource  :session

  map.search    '/search', :controller => 'search', :action => 'index'
  map.search_google '/search/google', :controller => 'search', :action => 'google' # for SEO

  map.login     '/login',         :controller => 'sessions', :action => 'new'
  map.logout    '/logout',        :controller => 'sessions', :action => 'destroy'

  map.with_options :path_prefix => '/info' do |info|
    info.root         :controller => 'home', :action => 'info'
    info.info_icons   'icons', :controller => 'home', :action => 'icons'
    info.info_hash    'hash', :controller => 'feeds', :action => 'hash_info'
    info.info_add     'add', :controller => 'feeds', :action => 'add_info'
    info.info_user    'user/:user_slug', :controller => 'users', :action => 'info'
    info.info_tags    'tags', :controller => 'tags', :action => 'info_index'
    info.info_tag     'tag/:tag', :controller => 'tags', :action => 'info'
    info.info_feed    ':podcast_slug/feed/:id', :controller => 'feeds', :action => 'info'
    info.info_review  ':podcast_slug/reviews/:id', :controller => 'reviews', :action => 'info'
    info.info_episode ':podcast_slug/:episode', :controller => 'episodes', :action => 'info'
    info.info_source  ':podcast_slug/:episode/:id', :controller => 'sources', :action => 'info'
    info.info_podcast ':podcast_slug', :controller => 'podcasts', :action => 'info'
  end
  

  map.with_options :controller => 'tags' do |t|
    t.tags        '/tags',            :action => 'index'
    t.tags        '/tag',             :action => 'index'
    t.tag         '/tag/:tag',        :action => 'show'
    t.search_tag  '/tag/:tag/search', :action => 'search'
  end
  
  map.with_options :controller => 'users' do |u|
    u.favoriters      '/:podcast_slug/favoriters',  :action => "favoriters"
    u.signup          '/signup',                    :action => 'new'
    u.activate        '/activate/:activation_code', :action => 'activate'
    u.send_password   '/send_password',             :action => 'send_password'
    u.reset_password  '/reset_password/:code',      :action => 'reset_password', :code => nil
    u.claim           '/claim',                     :action => 'claim'                       # claim & set_password are like send_password
    u.set_password    '/claim/:code',               :action => 'set_password', :code => nil  # & reset_password, but with different wording
    u.forgot_password '/forgot',                    :action => 'forgot_password'
    u.all_users       '/user',                      :action => 'index'
    u.user            '/user/:user_slug',           :action => 'show', :conditions => {:method => :get}
    u.user            '/user/:user_slug',           :action => 'update', :conditions => {:method => :put}
  end

  map.add_feed    '/add',         :controller => 'feeds',      :action => 'new'
  map.status      '/status',      :controller => 'feeds',      :action => 'status'

  map.with_options :controller => 'home' do |h|
    h.root                        :action => 'home'
    h.use         '/use',         :action => 'use'
    h.privacy     '/privacy',     :action => 'privacy'
    h.stats       '/stats',       :action => 'stats'
    h.team        '/team',        :action => 'team'
    h.guide       '/guide',       :action => 'guide'
  end

  map.with_options :controller => 'podcasts' do |p|
    p.podcasts         '/all',                    :action => 'index'
    p.all              '/all',                    :action => 'index'
    p.popular          '/popular',                :action => 'popular'
    p.podcast          '/:podcast_slug',          :action => 'destroy', :conditions => {:method => :delete}
    p.podcast          '/:podcast_slug',          :action => 'show',    :conditions => {:method => :get}
    p.podcast          '/:podcast_slug',          :action => 'update',  :conditions => {:method => :put}
    p.edit_podcast     '/:podcast_slug/edit',     :action => 'edit',    :conditions => {:method => :get}
    p.favorite_podcast '/:podcast_slug/favorite', :action => 'favorite'
    p.cover            '/:podcast_slug/cover',    :action => 'cover'
    p.recs             '/:podcast_slug/recs',     :action => 'recs'
    p.podcast_info     '/:podcast_slug/info',     :action => 'info'
  end

  map.positive_reviews '/:podcast_slug/reviews/positive', :controller => 'reviews', :filter => 'positive'
  map.negative_reviews '/:podcast_slug/reviews/negative', :controller => 'reviews', :filter => 'negative'
  map.with_options :controller => 'reviews' do |r|
    r.rate_review      '/:podcast_slug/reviews/:id/rate/:rating', :controller => 'reviews', :action => 'rate'
  end

  map.with_options :controller => 'feeds' do |f|
    f.plain_feed   '/:podcast_slug/plain/:id.xml',   :action => 'show', :type => :plain
    f.magnet_feed  '/:podcast_slug/magnet/:id.xml',  :action => 'show', :type => :magnet
    f.torrent_feed '/:podcast_slug/torrent/:id.xml', :action => 'show', :type => :torrent
  end

  map.with_options :controller => 'episodes' do |e|
    e.podcast_episodes '/:podcast_slug/episodes',         :action => 'index'
    e.episode          '/:podcast_slug/:episode',         :action => 'show'
    e.search_podcast_episodes '/:podcast_slug/episodes/search', :action => 'search'
  end
end
