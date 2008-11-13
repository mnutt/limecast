require File.dirname(__FILE__) + '/../spec_ui_helper'

describe "Adding Podcast" do
  before(:all) do
    setup_browser
  end
  
  it 'should successfully add a podcast' do
    browser.go("/add")
    browser.text_field(:name, "feed[url]").set("http://feeds.feedburner.com/WinelibraryTV")
    browser.button(:value, "Add").click
    # assert_select "div.status_message", /Getting RSS/
    try_for(60) do
      assert_select "div.status_message", /Yum/
    end
  end
  
  after(:all) do
    teardown_browser
  end
end

