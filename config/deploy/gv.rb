# An alias for production
set :stage, :production

set :domain, 'gv.limewire.com'

role :web, domain
role :app, domain
role :db,  domain, :primary => true
