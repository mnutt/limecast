ActionController::Routing::Routes.draw do |map|
  # Resources
  map.resources :categories
  map.resources :reviews, :path_prefix => '/:podcast_slug'
  map.resources :episodes
  map.resources :feeds
  
  map.admin '/admin', :controller => 'admin', :action => 'index'
  map.namespace :admin do |admin|
    admin.resources :podcasts
    admin.resources :episodes
    admin.resources :tags, :member => { :merge => :any }
    admin.resources :users

    admin.approve_podcast   '/podcasts/approve', :action => "approve", :controller => "podcasts"
    admin.blacklist_podcast '/podcasts/blacklist/:podcast_slug', :action => "blacklist", :controller => "podcasts"
  end

  map.resource  :session
  map.resources :users
  map.resources :user_taggings

  map.search    '/search', :controller => 'search', :action => 'index'
  map.search_google '/search/google', :controller => 'search', :action => 'google' # for SEO

  map.login     '/login',         :controller => 'sessions', :action => 'new'
  map.logout    '/logout',        :controller => 'sessions', :action => 'destroy'

  map.namespace :info do |info|
    info.root                    :controller => 'home',  :action => 'info'
    info.stats      '/stats',    :controller => 'home',  :action => 'stats'
    info.stats      '/use',      :controller => 'home',  :action => 'usage' # use() is already used by the ToS page
    info.ihash      '/hash',     :controller => 'feeds', :action => 'hash'
    info.add        '/add',      :controller => 'feeds', :action => 'add'
    info.icons      '/icons',    :controller => 'home',  :action => 'icons'
    info.tags       '/tags',     :controller => 'tags',  :action => 'index'
    info.tag        '/tag/:tag', :controller => 'tags',  :action => 'show'
    info.user       '/user/:user_slug', :controller => 'users', :action => 'info', :user_slug => ''
    info.feed       '/:podcast_slug/feed/:id', :controller => 'feeds', :action => 'show'
    info.review     '/:podcast_slug/reviews/:id', :controller => 'reviews', :action => 'info'
    info.episode    '/:podcast_slug/:episode', :controller => 'episodes', :action => 'show'
    info.source     '/:podcast_slug/:episode/:id', :controller => 'sources', :action => 'show'
    info.podcast    '/:podcast_slug', :controller => 'podcasts', :action => 'show'
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
    h.team        '/team',        :action => 'team'
    h.guide       '/guide',       :action => 'guide'
  end

  map.with_options :controller => 'podcasts' do |p|
    p.podcasts         '/all.:format',            :action => 'index'
    p.all              '/all',                    :action => 'index'
    p.popular          '/popular',                :action => 'popular'
    p.podcast          '/:podcast_slug',          :action => 'destroy', :conditions => {:method => :delete}
    p.podcast          '/:podcast_slug',          :action => 'show',    :conditions => {:method => :get}
    p.podcast          '/:podcast_slug',          :action => 'update',  :conditions => {:method => :put}
    p.edit_podcast     '/:podcast_slug/edit',     :action => 'edit',    :conditions => {:method => :get}
    p.favorite_podcast '/:podcast_slug/favorite', :action => 'favorite',:conditions => {:method => :post}
    p.cover            '/:podcast_slug/cover',    :action => 'cover'
    p.recs             '/:podcast_slug/recs',     :action => 'recs'
    p.podcast_info     '/:podcast_slug/info',     :action => 'info'
  end

  map.positive_reviews '/:podcast_slug/reviews/positive', :controller => 'reviews', :filter => 'positive'
  map.negative_reviews '/:podcast_slug/reviews/negative', :controller => 'reviews', :filter => 'negative'
  map.with_options :controller => 'reviews' do |r|
    r.rate_review '/:podcast_slug/reviews/:id/rate/:rating', :controller => 'reviews', :action => 'rate'
  end

  map.with_options :controller => 'feeds' do |f|
    f.plain_feed   '/plain_feed/:id.xml',   :action => 'show', :type => :plain
    f.magnet_feed  '/magnet_feed/:id.xml',  :action => 'show', :type => :magnet
    f.torrent_feed '/torrent_feed/:id.xml', :action => 'show', :type => :torrent
  end
  
  map.with_options :controller => 'sources' do |f|
    f.torrent_file '/torrent_file/:id.torrent', :action => 'show', :format => 'torrent'
  end

  map.with_options :controller => 'episodes' do |e|
    e.podcast_episodes '/:podcast_slug/episodes',         :action => 'index'
    e.episode          '/:podcast_slug/:episode',         :action => 'show'
    e.search_podcast_episodes '/:podcast_slug/episodes/search', :action => 'search'
  end
end
