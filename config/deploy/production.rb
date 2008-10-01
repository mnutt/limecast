set :domain, 'gv.limewire.com'

role :web, domain
role :app, domain
role :db,  domain, :primary => true
