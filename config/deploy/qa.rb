set :branch, "working_master"
set :domain, "localhost"

role :web, domain
role :app, domain
role :db,  domain, :primary => true
