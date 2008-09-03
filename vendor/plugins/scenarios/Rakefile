require 'rubygems'
gem 'rake'
require 'rake'
require 'rake/rdoctask'
require 'yaml'

require "#{File.dirname(__FILE__)}/spec/environment"

config = YAML.load(IO.read(DB_CONFIG_FILE))
databases = config.keys

desc "Run all specs using all databases"
task :spec => databases.map { |db| "spec:#{db}" }

databases.each do |db|
  desc "Run all specs using #{db}"
  task "spec:#{db}" => ["spec:libs:checkout", "db:#{db}:prepare"] do
    ENV['DB'] = db
    require "#{RSPEC_ROOT}/lib/spec/rake/spectask"
    puts "Running tests with #{db}..."
    Spec::Rake::SpecTask.new "spec:#{db}" do |t|
      t.spec_opts = ['--options', "\"#{SPEC_ROOT}/spec.opts\""]
      puts "#{SPEC_ROOT}/**/*_spec.rb"
      t.spec_files = FileList["#{SPEC_ROOT}/**/*_spec.rb"]
    end
  end
  
  desc "Prepare the #{db} test database"
  task "db:#{db}:prepare" do
    cd PLUGIN_ROOT do
      name = config[db][:database]
      case db
      when "mysql"
        system "mysqladmin -uroot drop #{name} --force"
        system "mysqladmin -uroot create #{name}"
      when "sqlite3"
        rm_rf name
        touch name
      end
      require "#{ACTIVERECORD_ROOT}/lib/activerecord"
      ActiveRecord::Base.silence do
        ActiveRecord::Base.configurations = config
        ActiveRecord::Base.establish_connection db
        load DB_SCHEMA_FILE
      end
    end
  end
end

namespace :spec do
  namespace :libs do
    desc "Prepare workspace for running our specs"
    task :checkout do
      mkdir_p SUPPORT_LIB
      libs = {
        RSPEC_ROOT          => "http://rspec.rubyforge.org/svn/trunk/rspec",
        RSPEC_ON_RAILS_ROOT => "http://rspec.rubyforge.org/svn/trunk/rspec_on_rails",
        ACTIVERECORD_ROOT   => "http://svn.rubyonrails.org/rails/trunk/activerecord/",
        ACTIVESUPPORT_ROOT  => "http://svn.rubyonrails.org/rails/trunk/activesupport/"
      }
      needed = libs.keys.select { |dir| not File.directory?(dir) }
      if needed.empty?
        puts "Support libraries are in place. Skipping checkout."
      else
        needed.each { |root| system "svn export #{libs[root]} #{root}" }
      end
    end
    
    desc "Remove libs from tmp directory"
    task :clean do
      rm_rf SUPPORT_LIB
      puts "cleaned #{SUPPORT_LIB}"
    end
  end
end

Rake::RDocTask.new(:doc) do |r|
  r.title = "Rails Scenarios Plugin"
  r.main = "README"
  r.options << "--line-numbers"
  r.rdoc_files.include("README", "LICENSE", "lib/**/*.rb")
  r.rdoc_dir = "doc"
end
  
task :default => :spec