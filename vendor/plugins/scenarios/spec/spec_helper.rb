require File.dirname(__FILE__) + "/../spec/environment"

unless defined? DATABASE_ADAPTER
  $: << "#{SPEC_ROOT}"
  $: << "#{PLUGIN_ROOT}/lib"
  $: << "#{RSPEC_ROOT}/lib"
  $: << "#{ACTIVERECORD_ROOT}/lib"
  $: << "#{ACTIVESUPPORT_ROOT}/lib"
  $: << "#{RSPEC_ON_RAILS_ROOT}/lib"

  require 'spec'
  require 'activesupport'
  require 'activerecord'
  require 'scenarios'
  require 'scenarios/dsl/extensions'
  require 'logger'

  RAILS_DEFAULT_LOGGER = Logger.new("#{SUPPORT_TEMP}/test.log")
  RAILS_DEFAULT_LOGGER.level = Logger::DEBUG
  ActiveRecord::Base.logger = RAILS_DEFAULT_LOGGER
  
  DATABASE_ADAPTER = ENV['DB'] || 'sqlite3'
  ActiveRecord::Base.configurations = YAML.load(IO.read(DB_CONFIG_FILE))
  ActiveRecord::Base.establish_connection DATABASE_ADAPTER
  
  require 'models'
end