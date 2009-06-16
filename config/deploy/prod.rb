set :domain, 'beta.limecast.com'

role :web, domain
role :app, domain
role :db,  domain, :primary => true
