if config.environment == "test"
  require 'scenarios'
  require 'spec/rails'
  require 'scenarios/dsl/extensions'
end