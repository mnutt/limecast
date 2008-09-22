ActionController::Routing::Routes.draw do |map|
  # Resources
  map.resources :categories
  map.resources :comments
  map.resources :podcasts
  map.resources :tags

  map.admin '/admin', :controller => 'admin', :action => 'index'
  map.namespace :admin do |admin|
    admin.resources :podcasts
    admin.resources :episodes
    admin.resources :tags, :member => { :merge => :any }
    admin.resources :users
  end

  map.resources :users
  map.resource  :session

  map.search    '/search/:query', :controller => 'podcasts', :action => 'search'

  map.signup    '/signup',        :controller => 'users',    :action => 'new'
  map.login     '/login',         :controller => 'sessions', :action => 'new'
  map.logout    '/logout',        :controller => 'sessions', :action => 'destroy'

  map.activate  '/activate/:activation_code', :controller => 'users', :action => 'activate'
  map.reset_password '/reset_password/:code', :controller => 'users', :action => 'reset_password', :code => nil
  map.send_password  '/send_password',        :controller => 'users', :action => 'send_password',  :code => nil
  map.forgot_password '/forgot_password',     :controller => 'users', :action => 'forgot_password'

  map.root                        :controller => 'home',     :action => 'home'
  map.add_podcast '/add',         :controller => 'podcasts', :action => 'new'
  map.status      '/status/*feed',:controller => 'podcasts', :action => 'status'
  map.all         '/all',         :controller => 'podcasts', :action => 'index'
  map.search      '/search',      :controller => 'podcasts', :action => 'search'
  map.all_users   '/users',       :controller => 'users',    :action => 'index'
  map.user        '/user/:user',  :controller => 'users',    :action => 'show'
  map.tag         '/tag/:tag',    :controller => 'tags',     :action => 'show'

  map.use         '/use',         :controller => 'home',     :action => 'use'
  map.privacy     '/privacy',     :controller => 'home',     :action => 'privacy'
  map.stats       '/stats',       :controller => 'home',     :action => 'stats'
  map.team        '/team',        :controller => 'home',     :action => 'team'
  map.guide       '/guide',       :controller => 'home',     :action => 'guide'

  map.rate_review      '/:podcast/reviews/:id/rate/:rating', :controller => 'comments', :action => 'rate'
  map.positive_reviews '/:podcast/reviews/positive', :controller => 'comments', :filter => 'positive'
  map.negative_reviews '/:podcast/reviews/negative', :controller => 'comments', :filter => 'negative'
  map.resources :reviews, :controller => 'comments', :path_prefix => '/:podcast'

  map.podcast_episodes '/:podcast/episodes',         :controller => 'episodes', :action => 'index'
  map.episode          '/:podcast/:episode',         :controller => 'episodes', :action => 'show'

  map.podcast          '/:podcast',                  :controller => 'podcasts', :action => 'show'
end
