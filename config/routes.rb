ActionController::Routing::Routes.draw do |map|
  # Resources
  map.resources :categories
  map.resources :reviews
  map.resources :podcasts
  map.resources :episodes
  map.resources :feeds
  
  map.admin '/admin', :controller => 'admin', :action => 'index'
  map.namespace :admin do |admin|
    admin.resources :podcasts
    admin.resources :episodes
    admin.resources :tags, :member => { :merge => :any }
    admin.resources :users
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
		u.favoriters       '/:podcast_slug/favoriters', :action => "favoriters"
    u.signup  '/signup',        :controller => 'users',    :action => 'new'
    u.activate  '/activate/:activation_code', :action => 'activate'
    u.reset_password '/reset_password/:code', :action => 'reset_password', :code => nil
    u.send_password  '/send_password',        :action => 'send_password',  :code => nil
    u.forgot_password '/forgot',              :action => 'forgot_password'
  end

  map.status      '/status',      :controller => 'feeds',      :action => 'status'
  map.all_users   '/user',        :controller => 'users',      :action => 'index'
  map.user        '/user/:user_slug',  :controller => 'users', :action => 'show', :conditions => {:method => :get}
  map.user        '/user/:user_slug',  :controller => 'users', :action => 'update', :conditions => {:method => :put}

  map.with_options :controller => 'home' do |h|
    h.root                        :action => 'home'
    h.admin       '/icons',       :action => 'icons'
    h.use         '/use',         :action => 'use'
    h.privacy     '/privacy',     :action => 'privacy'
    h.stats       '/stats',       :action => 'stats'
    h.team        '/team',        :action => 'team'
    h.guide       '/guide',       :action => 'guide'
  end

  map.with_options :controller => 'podcasts' do |p|
    p.add_podcast '/add',                    :action => 'new'
    p.all         '/popular',                :action => 'index'
    p.cover            '/:podcast_slug/cover',    :action => 'cover'
    p.recs             '/:podcast_slug/recs',     :action => 'recs'
    p.favorite_podcast '/:podcast_slug/favorite', :action => 'favorite'
    p.podcast          '/:podcast_slug/info',     :action => 'info'
    p.podcast          '/:podcast_slug',          :action => 'show',   :conditions => {:method => :get}
    p.podcast          '/:podcast_slug',          :action => 'update', :conditions => {:method => :put}
  end

  map.positive_reviews '/:podcast_slug/reviews/positive', :controller => 'reviews', :filter => 'positive'
  map.negative_reviews '/:podcast_slug/reviews/negative', :controller => 'reviews', :filter => 'negative'
  map.with_options :controller => 'reviews' do |r|
    r.rate_review      '/:podcast_slug/reviews/:id/rate/:rating', :controller => 'reviews', :action => 'rate'
    r.resources :reviews, :path_prefix => '/:podcast_slug', :collection => {:search => :get}
  end

  map.with_options :controller => 'episodes' do |e|
    e.podcast_episodes '/:podcast_slug/episodes',         :action => 'index'
    e.episode          '/:podcast_slug/:episode',         :action => 'show'
    e.search_podcast_episodes '/:podcast_slug/episodes/search', :action => 'search'
  end
end
