ENV['DO_NOT_LOAD_FEED_OBSERVER'] = 'false'
require 'rubygems'
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

def sign_in(user, suffix = 'global')
  browser.text_field(:id, "login_#{suffix}").set(user.login)
  browser.text_field(:id, "password_#{suffix}").set(user.password)
  browser.button(:id, "signin_#{suffix}").click
end

def should_be_signed_in?(user)
  html.should have_tag("li.user a", %r{#{@user.login}})
end

def should_not_be_signed_in?(user)
  html.should_not have_tag("li.user a", %r{#{@user.login}})
end

def try_for(seconds, &block)
  seconds.to_i.times do
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
  attr_accessor :url, :current

  def go(url)
    self.current = File.join(@url, url)
    self.goto(self.current)
  end

  def refresh
    self.goto(self.current)
  end

  def text_area(how, what)
    f = self.text_field(how, what)
    def f.tag; "TEXTAREA"; end
    f
  end
end

module Watir
  module Container

    def execute(javascript)
      @scripter.send(:execute, javascript)
    end

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
