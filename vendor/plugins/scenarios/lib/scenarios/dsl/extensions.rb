require File.dirname(__FILE__) + "/extensions/behaviour"
require File.dirname(__FILE__) + "/extensions/example"

Test::Unit::TestCase.module_eval do
  extend Scenarios::DSL::ClassMethods
  include Scenarios::DSL::ExampleExtensions
end