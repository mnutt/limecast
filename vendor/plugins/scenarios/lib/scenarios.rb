require File.dirname(__FILE__) + '/scenarios/extensions'
require 'active_record/fixtures'

module Scenario
  # Thrown by Scenario.load when it cannot find a specific senario.
  class NameError < ::NameError; end
  
  class << self
    mattr_accessor :load_paths
    self.load_paths = ["#{RAILS_ROOT}/spec/scenarios", "#{RAILS_ROOT}/test/scenarios"]
    
    # Load a scenario by name. <tt>scenario_name</tt> can be a string, symbol,
    # or the scenario class.
    def load(scenario_name)
      klass = scenario_name.to_scenario
      klass.load
      klass
    end
  end
  
  # This helper module contains the #create_record method and is mixed into
  # Scenario::Base and RSpec specs.
  module TableMethods
    attr_accessor :table_config
    delegate :table_readers, :blasted_tables, :record_metas, :symbolic_names_to_id, :to => :table_config
    
    # Insert a record into the database, add the appropriate helper methods
    # into the scenario and spec, and return the ID of the inserted record:
    #
    #   create_record :event, :name => "Ruby Hoedown"
    #   create_record :event, :hoedown, :name => "Ruby Hoedown"
    #
    # The first form will create a new record in the given table (first
    # parameter) with the appropriate attributes.
    #
    # The second form is exactly like the first, except for the fact that it
    # requires that you pass a symbolic name as the second parameter. The
    # symbolic name will allow you access to the record through a couple of
    # helper methods:
    #
    #   events(:hoedown)    # The hoedown event
    #   event_id(:hoedown)  # The ID of the hoedown event
    #
    # These helper methods are only accessible for a particular table after
    # you have inserted a record into that table using <tt>create_record</tt>.
    def create_record(class_identifier, *args)
      symbolic_name, attributes = extract_creation_arguments(args)
      record_meta = (record_metas[class_identifier] ||= RecordMeta.new(class_identifier))
      record      = ScenarioRecord.new(record_meta, attributes, symbolic_name)
      ActiveRecord::Base.silence do
        blast_table(record_meta.table_name) unless blasted_tables.include?(record_meta.table_name)
        ActiveRecord::Base.connection.insert_fixture(record.to_fixture, record_meta.table_name)
        symbolic_names_to_id[record_meta.table_name][record.symbolic_name] = record.id
        update_table_readers(symbolic_names_to_id, record_meta)
      end
      record.id
    end
    
    def blast_table(name) # :nodoc:
      ActiveRecord::Base.silence do
        ActiveRecord::Base.connection.delete "DELETE FROM #{name}", "Scenario Delete"
      end
      blasted_tables << name
    end
    
    private
      
      def extract_creation_arguments(arguments)
        if arguments.size == 2 && arguments.last.kind_of?(Hash)
          arguments
        elsif arguments.size == 1 && arguments.last.kind_of?(Hash)
          [nil, arguments[0]]
        else
          [nil, Hash.new]
        end
      end
      
      def update_table_readers(ids, record_meta)
        table_readers.send :define_method, record_meta.id_reader do |symbolic_name|
          record_id = ids[record_meta.table_name][symbolic_name]
          raise ActiveRecord::RecordNotFound, "No object is associated with #{record_meta.table_name}(:#{symbolic_name})" unless record_id
          record_id
        end
        table_readers.send :define_method, record_meta.record_reader do |symbolic_name|
          record_meta.record_class.find(send(record_meta.id_reader, symbolic_name))
        end
        metaclass.send :include, table_readers
      end
      
      def metaclass
        (class << self; self; end)
      end
      
      class RecordMeta # :nodoc:
        attr_reader :class_name, :record_class, :table_name
        
        def initialize(class_identifier)
          @class_identifier = class_identifier
          @class_name       = resolve_class_name(class_identifier)
          @record_class     = class_name.constantize
          @table_name       = record_class.table_name
        end
        
        def timestamp_columns
          @timestamp_columns ||= begin
            timestamps = %w(created_at created_on updated_at updated_on)
            columns.select do |column|
              timestamps.include?(column.name)
            end
          end
        end

        def columns
          @columns ||= connection.columns(table_name)
        end
        
        def connection
          record_class.connection
        end
        
        def id_reader
          @id_reader ||= begin
            reader = ActiveRecord::Base.pluralize_table_names ? table_name.singularize : table_name
            "#{reader}_id".to_sym
          end
        end
        
        def record_reader
          table_name.to_sym
        end
        
        def resolve_class_name(class_identifier)
          case class_identifier
          when Symbol
            class_identifier.to_s.singularize.camelize
          when Class
            class_identifier.name
          when String
            class_identifier
          end
        end
      end
      
      class ScenarioRecord # :nodoc:
        attr_reader :record_meta, :symbolic_name
        
        def initialize(record_meta, attributes, symbolic_name = nil)
          @record_meta   = record_meta
          @attributes    = attributes.stringify_keys
          @symbolic_name = symbolic_name || object_id
          
          install_default_attributes!
        end
        
        def id
          @attributes['id']
        end
        
        def to_hash
          @attributes
        end
        
        def to_fixture
          Fixture.new(to_hash, record_meta.class_name)
        end
        
        def install_default_attributes!
          @attributes['id'] ||= symbolic_name.to_s.hash.abs
          install_timestamps!
        end
        
        def install_timestamps!
          record_meta.timestamp_columns.each do |column|
            @attributes[column.name] = now(column) unless @attributes.key?(column.name)
          end
        end
        
        def now(column)
          now = ActiveRecord::Base.default_timezone == :utc ? column.klass.now.utc : column.klass.now
          now.to_s(:db)
        end
      end
  end
  
  module Loaders # :nodoc:
    def load_scenarios(scenario_classes)
      self.table_config = Config.new
      @loaded_scenarios = []
      previous_scenario = nil
      scenario_classes.each do |scenario_class|
        scenario = scenario_class.new(table_config)
        if previous_scenario
          scenario_class.helpers.extend previous_scenario.class.helpers
          scenario_class.send :include, previous_scenario.class.helpers
          scenario.table_readers.extend previous_scenario.table_readers
        end
        scenario.load
        self.class.send :include, scenario_class.helpers
        self.class.send :include, scenario.table_readers
        previous_scenario = scenario
        @loaded_scenarios << scenario
      end
    end
  end

  class Base
    class << self
      # Class method to load the scenario. Used internally by the Scenarios
      # plugin.
      def load
        new.load_scenarios(used_scenarios + [self])
      end
      
      # Class method for your own scenario to define helper methods that will
      # be included into the scenario and all specs that include the scenario
      def helpers(&block)
        mod = (const_get(:Helpers) rescue const_set(:Helpers, Module.new))
        mod.module_eval(&block) if block_given?
        mod
      end
      
      # Class method for your own scenario to define the scenarios that it
      # depends on. If your scenario depends on other scenarios those
      # scenarios will be loaded before the load method on your scenario is
      # executed.
      def uses(*scenarios)
        names = scenarios.map(&:to_scenario).reject { |n| used_scenarios.include?(n) }
        used_scenarios.concat(names)
      end
      
      # Class method that returns the scenarios used by your scenario.
      def used_scenarios # :nodoc:
        @used_scenarios ||= []
        @used_scenarios = (@used_scenarios.collect(&:used_scenarios) + @used_scenarios).flatten.uniq
      end
      
      # Returns the scenario class.
      def to_scenario
        self
      end
    end
    
    include TableMethods
    include Loaders
    
    # Initialize a scenario with a configuration. Used internally by the
    # Scenarios plugin.
    def initialize(config = Config.new)
      self.table_config = config
      self.extend table_config.table_readers
      self.extend self.class.helpers
    end
    
    # This method should be implemented in your own scenarios.
    def load
    end
    
    # Unload a scenario. Used internally by the Scenarios plugin.
    def unload
      record_metas.each_value { |meta| blast_table(meta.table_name) }
    end
  end
  
  class Config # :nodoc:
    attr_reader :blasted_tables, :record_metas, :table_readers, :symbolic_names_to_id
    def initialize
      @blasted_tables       = Set.new,
      @record_metas         = Hash.new,
      @table_readers        = Module.new,
      @symbolic_names_to_id = Hash.new {|h,k| h[k] = Hash.new}
    end
  end
  
end

# The scenarios namespace module.
Scenarios = Scenario