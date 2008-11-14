ENV['LOAD_FEED_OBSERVER']='true'
require 'safariwatir'
require 'hpricot'
require File.dirname(__FILE__) + '/spec_helper'

Spec::Runner.configure do |config|
  config.before(:all) { setup_browser }
  config.before(:each) { reset_db }
  config.use_transactional_fixtures = false
end

def reset_db
  r = ActiveRecord::Base.connection.execute('show tables')
  while table = r.fetch_row
    next if table.first == 'schema_migrations'
    ActiveRecord::Base.connection.execute("delete from #{table.first}")
  end
end

def setup_browser
  return if @browser
  @browser = Watir::Safari.new
  @browser.extend(BrowserExtensions)
  @browser.url = "http://localhost:3003"
end

def teardown_browser
  return if @browser.nil?
  @browser.close rescue nil
end

def browser
  @browser
end

def html
  @browser.html
end

def try_for(seconds, &block)
  seconds.times do
    begin
      block.call
      return
    rescue
      sleep(1)
    end
  end
  block.call
end

module BrowserExtensions
  attr_writer :url

  def go(url)
    self.goto([@url, url].join)
  end
end

module Watir
  module Container
    class GenericElement < ContentElement
      attr_reader :tag
      def initialize(tag, scripter, how, what)
        @tag = tag
        super(scripter, how, what)
      end
    end

    def element(tag, how, what)
      GenericElement.new(tag, scripter, how, what)
    end
  end
end
