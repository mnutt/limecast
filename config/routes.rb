ActionController::Routing::Routes.draw do |map|
  # Resources
  map.resources :categories
  map.resources :reviews
  map.resources :podcasts
  map.resources :episodes
  map.resources :feeds
  map.resources :tags, :as => 'tag', :member => {:search => :get}, :controller => 'tags'

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

  map.login     '/login',         :controller => 'sessions', :action => 'new'
  map.logout    '/logout',        :controller => 'sessions', :action => 'destroy'

  map.with_options :controller => 'users' do |u|
    u.signup  '/signup',        :controller => 'users',    :action => 'new'
    u.activate  '/activate/:activation_code', :action => 'activate'
    u.reset_password '/reset_password/:code', :action => 'reset_password', :code => nil
    u.send_password  '/send_password',        :action => 'send_password',  :code => nil
    u.forgot_password '/forgot',              :action => 'forgot_password'
  end

  map.status      '/status',      :controller => 'feeds',    :action => 'status'
  map.all_users   '/user',        :controller => 'users',    :action => 'index'
  map.user        '/user/:user',  :controller => 'users',    :action => 'show', :conditions => {:method => :get}
  map.user        '/user/:user',  :controller => 'users',    :action => 'update', :conditions => {:method => :post}

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
    p.all         '/all',                    :action => 'index'
    p.cover            '/:podcast/cover',    :action => 'cover'
    p.recs             '/:podcast/recs',     :action => 'recs'
    p.favorite_podcast '/:podcast/favorite', :action => 'favorite'
    p.podcast          '/:podcast',          :action => 'show',   :conditions => {:method => :get}
    p.podcast          '/:podcast',          :action => 'update', :conditions => {:method => :post}
  end

  map.with_options :controller => 'reviews' do |r|
    r.resources :reviews, :path_prefix => '/:podcast', :collection => {:search => :get}
    r.rate_review      '/:podcast/reviews/:id/rate/:rating', :controller => 'reviews', :action => 'rate'
    r.positive_reviews '/:podcast/reviews/positive', :controller => 'reviews', :filter => 'positive'
    r.negative_reviews '/:podcast/reviews/negative', :controller => 'reviews', :filter => 'negative'
  end

  map.with_options :controller => 'episodes' do |e|
    e.podcast_episodes '/:podcast/episodes',         :action => 'index'
    e.episode          '/:podcast/:episode',         :action => 'show'
    e.search_podcast_episodes '/:podcast/episodes/search', :action => 'search'
  end
end
