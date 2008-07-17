set :domain, 'gv.limewire.com'

role :web, domain
role :app, domain
role :db,  domain, :primary => true

namespace :limespot do
  namespace :deploy do
    desc 'Rewrites the default host constant in production.rb, using the :domain parameter'
    task :rewrite_default_host, :roles => :app do
      run <<-CMD
        cd #{latest_release}/config/environments &&
        perl -i -pe "s|DEFAULT_HOST \s*= 'limespot\.com'|DEFAULT_HOST = '#{domain}'|g" production.rb
      CMD
    end
  end
end

after 'deploy:update_code', 'limespot:deploy:rewrite_default_host'
