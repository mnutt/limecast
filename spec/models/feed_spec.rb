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


describe Feed, "finding or creating owner" do
  before do
    @feed = Factory.build(:feed, :title => "FOoooooobar", :owner_email => "some.owner@here.com")
    @save_feed = lambda { @feed.save }
  end

  it "should set and create the passive owner if the owner doesn't exist" do
    @save_feed.should change { User.all.size }.by(1)
    @feed.owner.should == User.last
    @feed.owner.should be_passive
  end

  it "should find and set the owner if owner exists" do
    owner = Factory.create(:user, :email => @feed.owner_email)
    @save_feed.should_not change { User.all.size }
    @feed.owner.should == owner
  end
end