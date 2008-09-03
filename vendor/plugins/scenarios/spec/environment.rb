unless defined?(PLUGIN_ROOT)
  PLUGIN_ROOT         = File.expand_path(File.dirname(__FILE__) + "/..")
  RAILS_ROOT          = PLUGIN_ROOT
  SUPPORT_TEMP        = "#{PLUGIN_ROOT}/tmp"
  SUPPORT_LIB         = "#{SUPPORT_TEMP}/lib"
  ACTIVESUPPORT_ROOT  = "#{SUPPORT_LIB}/activesupport"
  ACTIVERECORD_ROOT   = "#{SUPPORT_LIB}/activerecord"
  RSPEC_ROOT          = "#{SUPPORT_LIB}/rspec"
  RSPEC_ON_RAILS_ROOT = "#{SUPPORT_LIB}/rspec_on_rails"
  SPEC_ROOT           = "#{PLUGIN_ROOT}/spec"
  DB_CONFIG_FILE      = "#{SPEC_ROOT}/database.yml"
  DB_SCHEMA_FILE      = "#{SPEC_ROOT}/schema.rb"
end