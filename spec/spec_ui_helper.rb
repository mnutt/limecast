ENV['LOAD_FEED_OBSERVER']='true'
require 'safariwatir'
require 'hpricot'
require File.dirname(__FILE__) + '/spec_helper'

def setup_browser
  @browser = Watir::Safari.new
  def @browser.url=(url)
    @url = url
  end
  def @browser.go(url)
    self.goto([@url, url].join)
  end
  @browser.url = "http://localhost:3003"
end

def teardown_browser
  @browser.kill! rescue nil
end

def browser
  @browser
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
      
