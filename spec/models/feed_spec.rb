require File.dirname(__FILE__) + '/../spec_helper'

describe Feed do
  before do
    @user = Factory.create(:user)
    @podcast = Factory.create(:podcast)
    @feed = @podcast.feeds.first
    @feed.update_attributes :finder => @user
    @feed.update_finder_score
  end

  it 'should recalculate the finder\'s score' do
    lambda { @feed.destroy }.should change { @user.score }.by(-1)
  end
end

describe Feed, "being claimed" do
  before do
    @feed = Factory.create(:feed, :finder_id => nil)
    @user = Factory.create(:user)
  end

  it "should set the finder_id to the one given" do
    lambda { @feed.claim_by(@user) }.should change { @feed.finder_id }
    @feed.reload.finder_id.should be(@user.id)
  end
end

describe Feed, "attributes" do
  before do
    @feed = Factory.create(:feed, :generator => "limecast.com/tracker")
    @feed2 = Factory.create(:feed, :generator => "http://limecast.com/tracker")
    @feed3 = Factory.create(:feed, :generator => "something else")
  end

  it "should select all LimeTracker feeds" do
    Feed.from_limetracker.all.should == [@feed, @feed2]
  end
end