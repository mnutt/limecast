require File.dirname(__FILE__) + '/../spec_ui_helper'

describe "Adding podcast while logged out" do
  before(:each) do
    sleep(1)
    Feed.destroy_all
    browser.go("/add")
    browser.text_field(:name, "feed[url]").set("http://feeds.feedburner.com/WinelibraryTV")
    browser.button(:value, "Add").click
  end
  
  it 'should immediately show the loading status' do
    html.should have_tag("div.status_message", /Getting RSS/)
  end
  
  it 'should eventually show success' do
    try_for(10) do
      html.should have_tag("div.status_message", /Yum/)
    end
  end
end

describe "Adding podcast while logged in" do
  before(:each) do
    sleep(1)
    Feed.destroy_all
    @user = Factory.create(:user)
    browser.go("/add")
    browser.element("LI", :class, "signup").click
    browser.text_field(:name, "user[login]").set(@user.login)
    browser.text_field(:name, "user[password]").set(@user.password)
    browser.button(:value, "Sign in").click
    sleep(3)
    browser.button(:value, "Sign in").click
    browser.button(:value, "Sign in").click
    raise User.authenticate(@user.login, "password").inspect
    sleep(3)
    #browser.text_field(:name, "feed[url]").set("http://feeds.feedburner.com/WinelibraryTV")
    #browser.button(:value, "Add").click
  end
  
  it 'should not show the inline signin' do
  end
end
