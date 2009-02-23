set :branch, "working_master"
set :domain, "172.17.1.101"
set :user, "limecast"
set :remote_home, "/var/www"
set :deploy_to, "/var/www/limecast"

set :deploy_via,      :copy
set :deploy_strategy, :export

role :web, domain
role :app, domain
role :db,  domain, :primary => true
