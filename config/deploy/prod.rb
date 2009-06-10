# An alias for production
set :stage, :production

set :domain, 'limecast.com'

role :web, domain
role :app, domain
role :db,  domain, :primary => true
