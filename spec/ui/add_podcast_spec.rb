require File.dirname(__FILE__) + '/../spec_ui_helper'

describe "Adding podcast while logged out" do
  before(:each) do
    browser.go("/add")
    browser.text_field(:name, "feed[url]").set("#{browser.url}/test_data/wine-library-tv.rss")
    browser.button(:value, "Add").click
  end

  it 'should immediately show the loading status' do
    html.should have_tag("div.status_message", /Getting RSS/)
  end

  it 'should initially have the inline signin hidden' do
  end

  it 'should eventually show success' do
    try_for(10.seconds) do
      html.should have_tag("div.status_message", /Yum/)
    end
  end
end

describe "Adding podcast that is not a web address" do
  before(:each) do
    browser.go("/add")
    browser.text_field(:name, "feed[url]").set("asdf")
    browser.button(:value, "Add").click
  end

  it 'should show that it is not a web address' do
    try_for(10.seconds) do
      html.should have_tag("div.status_message", /not a web address/)
    end
  end
end

describe "Adding podcast while logged in" do
  before(:each) do
    @user = Factory.create(:user)

    browser.go("/")
    sign_in(@user)

    browser.go("/add")
    signed_in?(@user)

    browser.text_field(:name, "feed[url]").set("#{browser.url}/test_data/wine-library-tv.rss")
    browser.button(:value, "Add").click
  end

  it 'should not show the inline signin' do
    html.should_not have_tag("#full_width .quick_siginin")
  end
end
