require File.dirname(__FILE__) + '/../spec_ui_helper'

describe "Adding Podcast" do
  before(:all) do
    setup_browser
  end

  it 'should successfully add a podcast' do
    browser.go("/add")
    browser.text_field(:name, "feed[url]").set("http://feeds.feedburner.com/WinelibraryTV")
    browser.button(:value, "Add").click
    try_for(2) do
      html.should have_tag("div.status_message", /Getting RSS/)
    end
    try_for(10) do
      html.should have_tag("div.status_message", /Yum/)
    end
  end

  after(:all) do
    teardown_browser
  end
end

