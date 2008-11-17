require File.dirname(__FILE__) + '/../spec_ui_helper'

describe "Adding review to a podcast" do
  before(:each) do
    sleep(1)
    @feed = Feed.create(:url => "#{browser.url}/test_data/diggnation-quicktime-hd.rss")
    @feed.refresh
    @podcast = @feed.podcast
    browser.go(@podcast.clean_url)

    @user = Factory.create(:user)
  end

  it 'should be prompt user with a login box if they post a review without being logged in' do
    browser.text_field(:name, "review[title]").set("Diggnation Rulez")
    browser.text_area(:name, "review[body]").set("I think diggnation is the coooooolest show...")
    browser.button(:value, "Save").click

    browser.text_field(:id, "login_after_adding_review").set(@user.login)
    browser.text_field(:id, "password_after_adding_review").set(@user.password)
    browser.button(:id, "signin_after_adding_review").click

    html.should_not have_tag("div.after_adding_review div.response_container", /Email/)
  end
end
