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
    browser.execute('return $("#login_after_adding_review").visible();').should be_false

    add_review

    browser.execute('return $("#login_after_adding_review").visible();').should be_true
  end

  it 'should be able to log in using the inline login box' do
    should_not_be_signed_in?(@user)

    add_review

    sign_in(@user, "after_adding_review")

    should_be_signed_in?(@user)
  end

  it 'should not be able to add two reviews' do
    sign_in(@user)

    add_review

    browser.refresh

    browser.execute('return $("form.new_review").length;').should == 0
  end

  def add_review
    browser.text_field(:name, "review[title]").set("Diggnation Rulez")
    browser.text_area(:name, "review[body]").set("I think diggnation is the coooooolest show...")
    browser.button(:value, "Save").click
  end
end
