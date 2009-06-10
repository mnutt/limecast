# set your dns to point staging.limecast.com to your staging server. at work it is 10.254.0.240
set :domain, 'beta.limecast.com'
set :branch, "master"
set :user, "limecast"
set :remote_home, "/var/www"
set :deploy_to, "/var/www/html"

role :web, domain
role :app, domain
role :db,  domain, :primary => true

