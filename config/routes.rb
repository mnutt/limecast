ActionController::Routing::Routes.draw do |map|
  # Resources
  map.resources :categories
  map.resources :reviews, :path_prefix => '/:podcast_slug'
  map.resources :episodes

  
  map.admin '/admin', :controller => 'admin', :action => 'index'
  map.namespace :admin do |admin|
    admin.resources :podcasts
    admin.resources :episodes
    admin.resources :tags, :member => { :merge => :any }
    admin.resources :users

    admin.blacklist_podcast '/podcasts/blacklist/:podcast_slug', :action => "blacklist", :controller => "podcasts"
  end

  map.resource  :session
  map.resources :users
  map.resources :user_taggings

  map.search    '/search', :controller => 'search', :action => 'show'
  map.search_google '/search/google', :controller => 'search', :action => 'google' # for SEO

  map.login     '/login',         :controller => 'sessions', :action => 'new'
  map.logout    '/logout',        :controller => 'sessions', :action => 'destroy'

  map.namespace :info do |info|
    info.sources    '/sources/:filter/:value', :controller => 'sources', :action => 'index', :filter => nil, :value => nil
    info.root                           :controller => 'home',  :action => 'info'
    info.stats      '/stats',           :controller => 'home',  :action => 'stats'
    info.stats      '/use',             :controller => 'home',  :action => 'usage' # use() is already used by the ToS page
    info.icons      '/icons',           :controller => 'home',  :action => 'icons'
    info.tags       '/tags',            :controller => 'tags',  :action => 'index'
    info.tag        '/tag/:tag',        :controller => 'tags',  :action => 'show'
    info.users      '/users',           :controller => 'users', :action => 'index'
    info.user       '/user/:user_slug', :controller => 'users', :action => 'show'
    info.authors    '/authors',         :controller => 'authors', :action => 'index'
    info.author     '/author/:author_slug', :controller => 'authors', :action => 'show'
    info.titles     '/titles',          :controller => 'podcasts', :action => 'titles'
    info.random     '/random',          :controller => 'podcasts', :action => 'random'
    info.podcasts_histogram '/podcasts/histogram', :controller => 'podcasts', :action => 'histogram'
    info.recent_podcasts '/recent_podcasts', :controller => 'podcasts', :action => 'recent'
    info.recent_episodes '/recent_episodes', :controller => 'episodes', :action => 'recent'
    info.ihash      '/hash',            :controller => 'podcasts', :action => 'hash'
    info.add        '/add',             :controller => 'podcasts', :action => 'add'
    info.feed       '/:podcast_slug/feed/:id', :controller => 'podcasts', :action => 'show'
    info.review     '/:podcast_slug/reviews/:id', :controller => 'reviews', :action => 'show'
    info.episode    '/:podcast_slug/:episode', :controller => 'episodes', :action => 'show'
    info.source     '/:podcast_slug/:episode/:id', :controller => 'sources', :action => 'show'
    info.podcast    '/:podcast_slug',   :controller => 'podcasts', :action => 'show'
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
    u.forgot_password '/forgot',                    :action => 'forgot_password'
    u.all_users       '/user',                      :action => 'index'
    u.user            '/user/:user_slug',           :action => 'show', :conditions => {:method => :get}
    u.user            '/user/:user_slug',           :action => 'update', :conditions => {:method => :put}
  end
  
  map.with_options :controller => 'authors' do |a|
    a.author  '/by/:author_slug', :action => 'show'
  end

  map.with_options :controller => 'home' do |h|
    h.root                            :action => 'home'
    h.surf        '/surf/:direction', :action => 'surf', :direction => nil, :conditions => {:method => :post}
    h.iphone      '/iphone.:format',  :action => 'iphone'
    h.use         '/use',             :action => 'use'
    h.privacy     '/privacy',         :action => 'privacy'
    h.team        '/team',            :action => 'team'
    h.guide       '/guide',           :action => 'guide'
  end

  map.with_options :controller => 'podcasts' do |p|
    p.podcasts         '/all.:format',              :action => 'index'
    p.all              '/all',                      :action => 'index'
    p.popular          '/popular.:format',          :action => 'popular'
    p.recently_updated '/recently_updated.:format', :action => 'recently_updated'
    p.add              '/add',                      :action => 'new'
    p.status           '/status',                   :action => 'status'
    p.podcast          '/podcasts',                 :action => 'create',  :conditions => {:method => :post}
    p.podcast          '/:podcast_slug',            :action => 'destroy', :conditions => {:method => :delete}
    p.podcast          '/:podcast_slug',            :action => 'show',    :conditions => {:method => :get}
    p.podcast          '/:podcast_slug',            :action => 'update',  :conditions => {:method => :put}
    p.edit_podcast     '/:podcast_slug/edit',       :action => 'edit',    :conditions => {:method => :get}
    p.favorite_podcast '/:podcast_slug/favorite',   :action => 'favorite',:conditions => {:method => :post}
    p.cover            '/:podcast_slug/cover',      :action => 'cover'
    p.recs             '/:podcast_slug/recs',       :action => 'recs'
    p.podcast_info     '/:podcast_slug/info',       :action => 'info'
    p.plain_feed       '/plain_feeds/:id.xml',      :action => 'feed', :type => :plain
    p.magnet_feed      '/magnet_feeds/:id.xml',     :action => 'feed', :type => :magnet
    p.torrent_feed     '/torrent_feeds/:id.xml',    :action => 'feed', :type => :torrent
  end

  map.positive_reviews '/:podcast_slug/reviews/positive', :controller => 'reviews', :filter => 'positive'
  map.negative_reviews '/:podcast_slug/reviews/negative', :controller => 'reviews', :filter => 'negative'
  map.with_options :controller => 'reviews' do |r|
    r.rate_review '/:podcast_slug/reviews/:id/rate/:rating', :controller => 'reviews', :action => 'rate'
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
