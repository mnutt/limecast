# An alias for production
set :stage, :production

set :domain, 'stage.limecast.com'

set :remote_home,   "/home/#{user}"
set :deploy_to,     "#{remote_home}/limecast.com"

role :web, domain
role :app, domain
role :db,  domain, :primary => true
