# set your dns to point staging.limecast.com to your staging server. at work it is 10.254.0.240
set :domain, 'staging.limecast.com'

role :web, domain
role :app, domain
role :db,  domain, :primary => true
