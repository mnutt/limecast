set :branch, "working_master"
set :domain, "localhost"
set :user, "root"
set :remote_home, "/var/www/html"
set :deploy_to, "/var/www/html/limecast.com"

role :web, domain
role :app, domain
role :db,  domain, :primary => true
