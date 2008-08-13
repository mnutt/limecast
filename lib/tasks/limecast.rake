require 'app/models/podcast'
namespace :limecast do
  desc "update all podcast episodes"
  task :update do
    Podcast.find(:all).each do |podcast|
      podcast.retrieve_episodes_from_feed
    end
  end

  desc "generate encryption key"
  task :generate_encryption_key do
    `test ! -f #{RAILS_ROOT}/private/encryption_key.txt || cp #{RAILS_ROOT}/private/encryption_key.txt #{RAILS_ROOT}/private/encryption_key.txt.1`
    require 'openssl'
    encryption_key = [ OpenSSL::Random.random_bytes(60) ].pack('m*')
    File.open("#{RAILS_ROOT}/private/encryption_key.txt", 'w') do |f|
      f.write(encryption_key)
    end
  end
end
