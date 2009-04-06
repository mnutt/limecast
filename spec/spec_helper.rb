# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] ||= "test"
$: << File.dirname(__FILE__)

ENV['DO_NOT_LOAD_FEED_OBSERVER'] ||= 'true'

require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'spec/autorun'
require 'spec/rails'
require 'factory_girl'
require 'thinking_sphinx'
require 'factories'

Spec::Runner.configure do |config|
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false

  # You can declare fixtures for each behaviour like this:
  #   describe "...." do
  #     fixtures :table_a, :table_b
  #
  # Alternatively, if you prefer to declare them only once, you can
  # do so here, like so ...
  #
  #   config.global_fixtures = :table_a, :table_b
  #
  # If you declare global fixtures, be aware that they will be declared
  # for all of your examples, even those that don't use them.
end

Dir[File.join(RAILS_ROOT, 'spec', 'matchers', '*')].each do |matcher|
  require matcher
  include File.basename(matcher, '.rb').camelize.constantize
end

# Run expectations on content_for blocks like so:
#   content_for(:sidebar).should have_tag(...)
def content_for(name)
  response.template.instance_variable_get("@content_for_#{name}")
end

def current_page
  { :size => 20, :current => 1 }
end

def login(user)
  controller.stub!(:current_user).and_return(user) if self.respond_to?(:controller)
  template.stub!(:current_user).and_return(user) if self.respond_to?(:template)
end

def logout
  controller.stub!(:current_user).and_return(nil) if self.respond_to?(:controller)
  template.stub!(:current_user).and_return(nil) if self.respond_to?(:template)
end

def http_auth(name='foo', password='bar')
  @request.env["HTTP_AUTHORIZATION"] = "Basic #{Base64.encode64("#{name}:#{password}")}"
end

def setup_actionmailer
  ActionMailer::Base.delivery_method = :test
  ActionMailer::Base.perform_deliveries = true
  ActionMailer::Base.deliveries = []
end

def reset_actionmailer
  ActionMailer::Base.deliveries.clear
end

# Returns a controller that has been initialized enough to make #url_for and
# #render_to_string calls against it.
def initialized_controller(controller_name = "sites", action = "parked", params = {})
  request = ActionController::TestRequest.new
  request.env["REQUEST_METHOD"] = "GET"
  request.assign_parameters(controller_name, action, params)

  response = ActionController::TestResponse.new
  response.session = request.session

  controller = "#{controller_name.camelize}Controller".constantize.new
  controller.process(request, response)
  controller.send(:erase_render_results)

  controller
end

class UploadedFile < StringIO
  attr_accessor :original_filename, :content_type

  def initialize(content, name, type)
    super(content)
    self.original_filename = name
    self.content_type      = type
  end
end

# Some mock helpers
#
# Instead of:
#   Post.should_receive(:comments).and_return mock("comments", :size => 5)
#
# Now:
#   Post.should_proxy(:comments).which_should_receive(:size).and_return(5)
#
module Spec
  module Mocks
    module Methods
      def should_find_and_return(obj)
        self.should_receive(:find).with(obj.id.to_s).and_return(obj)
      end

      def should_proxy(sym)
        returning Mock.new(sym.to_sym) do |mock|
          self.should_receive(sym).and_return(mock)
        end
      end

      alias :which_should_receive :should_receive
    end
  end
end

# Run presenter specs as if they were helper specs (provides access to url_for, etc.)
Spec::Example::ExampleGroupFactory.register(:presenter, Spec::Rails::Example::HelperExampleGroup)

class Spec::Rails::Example::PluginExampleGroup < Spec::Rails::Example::ViewExampleGroup
  def set_base_view_path(options)
    @controller.view_paths = ["#{RAILS_ROOT}/app/plugins"]
  end
end
Spec::Example::ExampleGroupFactory.register(:plugin, Spec::Rails::Example::PluginExampleGroup)

# Stub out ThinkingSphinx
module ThinkingSphinx::ActiveRecord
  def in_core_index?
    false
  end
end

module FetchExample
  def fetch
    File.open("#{RAILS_ROOT}/spec/data/example.xml").read
  end
end
module FetchRegularFeed
  def fetch
    File.open("#{RAILS_ROOT}/spec/data/regularfeed.xml").read
  end
end

class Podcast
  def download_log(*args); end
end

def mod_and_run_feed_processor(queued_feed, mod = FetchExample)
  fp = FeedProcessor.new(queued_feed)
  fp.extend(mod)
  fp.process
end
