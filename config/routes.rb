ActionController::Routing::Routes.draw do |map|
  # Resources
  map.resources :categories
  map.resources :comments
  map.resources :podcasts, :collection => { :feed_info => :any }
  map.resources :tags

  map.namespace :admin do |admin|
    admin.root :controller => 'admin', :action => 'index'
    admin.resources :podcasts
    admin.resources :episodes
    admin.resources :categories, :collection => { :order => :any }
  end

  map.resources :users
  map.resource  :session
  map.signup    '/signup', :controller => 'users',    :action => 'new'
  map.login     '/login',  :controller => 'sessions', :action => 'new'
  map.logout    '/logout', :controller => 'sessions', :action => 'destroy'
  map.activate  '/activate/:activation_code', :controller => 'users', :action => 'activate'

  map.root                        :controller => 'home',     :action => 'home'
  map.add_podcast '/add',         :controller => 'podcasts', :action => 'new'
  map.all         '/all',         :controller => 'podcasts', :action => 'index'
  map.search      '/search',      :controller => 'podcasts', :action => 'search'
  map.users       '/users',       :controller => 'users',    :action => 'index'
  map.user        '/user/:user',  :controller => 'users',    :action => 'show'
  map.tags        '/tag/:tag',    :controller => 'tags',     :action => 'show'

  map.podcast          '/:podcast',          :controller => 'podcasts', :action => 'show'
  map.podcast_episodes '/:podcast/episodes', :controller => 'episodes', :action => 'index'
  map.podcast_reviews  '/:podcast/reviews',  :controller => 'comments', :action => 'index'
  map.podcast_episode  '/:podcast/:episode', :controller => 'episodes', :action => 'show'
end
