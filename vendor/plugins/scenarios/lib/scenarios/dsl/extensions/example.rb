module Scenarios
  module DSL # :nodoc:
    
    module ExampleExtensions # :nodoc:
      include ::Scenarios::TableMethods
      include ::Scenarios::Loaders
    end
    
  end
end