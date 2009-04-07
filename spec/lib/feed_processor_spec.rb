require File.dirname(__FILE__) + '/../spec_helper'

# Feed is not in the system, creating it by url.
describe FeedProcessor, "being parsed" do

  before do
    @qf = QueuedFeed.create(:url => "http://google.com/rss.xml")
    mod_and_run_feed_processor(@qf, FetchExample)
    @feed = @qf.feed
  end

  it 'should set the title of the podcast' do
    @feed.podcast.reload.title.should == "All About Everything"
  end

  it 'should set the site link of the podcast' do
    @feed.podcast.reload.site.should == "http://www.example.com/podcasts/everything/index.html"
  end

  it 'should set the description of the podcast' do
    @feed.podcast.reload.description.should =~ /^All About Everything is a show about everything/
  end

  it 'should set the language of the podcast' do
    @feed.podcast.reload.language.should == "en-us"
  end

  it 'should set the generator of the podcast' do
    @feed.reload.generator.should == "http://limecast.com/tracker"
  end

  it 'should add tags' do
    @feed.podcast.tag_string.should include('technology', 'gadgets', 'tvandfilm')
    @feed.podcast.tags.size.should == 3
    @feed.podcast.taggers.should include(@feed.podcast.owner)
  end

  it 'should associate the podcast with the user as owner' do
    User.destroy_all

    user = Factory.create(:user, :email => "john.doe@example.com")
    @podcast = Factory.create(:podcast, :site => "http://www.example.com/")
    @feed = @podcast.feeds.first

    @qf = QueuedFeed.create(:url => @feed.url, :feed_id => @feed.id, :user => user)

    mod_and_run_feed_processor(@qf, FetchExample)

    @feed.reload.finder.should == user
    @feed.podcast.should be_kind_of(Podcast)
    @feed.podcast.owner.should == user
  end
end

describe FeedProcessor, "failing" do
  before do
    @qf = QueuedFeed.create(:url => "http://google.com/rss.xml")
    mod_and_run_feed_processor(@qf, FetchRegularFeed)
  end

  it 'should not create a Feed' do
    FeedProcessor.process(@qf)

    @qf.feed.should be_nil
  end
end


# Feed is already in the system, looking it up by url.
describe FeedProcessor, "being reparsed" do
  before do
    @qf = Factory.create(:queued_feed)
    mod_and_run_feed_processor(@qf, FetchExample)
    @feed = @qf.feed
  end

  it 'should set the title of the podcast' do
    @feed.podcast.reload.title.should == "All About Everything"
  end

  it 'should set the site link of the podcast' do
    @feed.podcast.reload.site.should == "http://www.example.com/podcasts/everything/index.html"
  end

  it 'should set the description of the podcast' do
    @feed.podcast.reload.description.should =~ /^All About Everything is a show about everything/
  end

  it 'should set the language of the podcast' do
    @feed.podcast.reload.language.should == "en-us"
  end

  it 'should set the generator of the podcast' do
    @feed.reload.generator.should == "http://limecast.com/tracker"
  end
end

describe Feed, "updating episodes" do
  before do
    @qf = Factory.create(:queued_feed)
    mod_and_run_feed_processor(@qf, FetchExample)
    @feed = @qf.feed
  end

  it 'should create some episodes' do
    @feed.podcast.episodes(true).count.should == 3
  end

  it 'should not duplicate episodes that already exist' do
    @feed.podcast.episodes(true).count.should == 3
    mod_and_run_feed_processor(@qf, FetchExample)
    @feed.podcast.episodes(true).count.should == 3
  end
end

describe Feed, "downloading the logo for its podcast" do
  before do
    @podcast = Factory.create(:podcast)
    @feed = @podcast.feeds.first
  end

  it 'should not set the logo_filename for a bad link' do
    @podcast.download_logo('http://google.com')
    @podcast.logo_file_name.should be_nil
  end
end

describe Feed, "being updated" do
  before do
    @podcast = Factory.create(:parsed_podcast, :owner_email => "john.doe@example.com", :feeds => [], :site => "http://www.example.com")
    @qf = Factory.create(:queued_feed)
    @feed = @qf.feed
    @feed.podcast_id = @podcast.id
    @feed.save
    @podcast.update_attributes :original_title => "The Whatever Podcast"
    @podcast.reload
  end

  it "should send an email out of if the podcast was changed at all" do
    setup_actionmailer
    lambda { mod_and_run_feed_processor(@qf, FetchExample) }.should change { ActionMailer::Base.deliveries.size }.by(1)
    ActionMailer::Base.deliveries.last.to_addrs.to_s.should == @podcast.editors.map(&:email).join(',')
    ActionMailer::Base.deliveries.last.body.should =~ /A podcast that you can edit has been updated because one of its feeds was changed/
    ActionMailer::Base.deliveries.last.body.should =~ /The Original Title was changed to All About Everything/
    reset_actionmailer
  end
end


describe Feed, "when a weird server error occurs" do
  before do
    @qf = Factory.create :queued_feed, :url => 'http://localhost:7'
    @podcast = Factory.create(:podcast, :feeds => [@qf.feed])
    @feed = @podcast.feeds.first
  end

  it 'should save the error that an unknown exception occurred' do
    FeedProcessor.process(@qf)

    @qf.error.should == "Errno::ECONNREFUSED"
  end
end

describe Feed, "being created" do
  before do
    @qf = Factory.create :queued_feed
    mod_and_run_feed_processor(@qf, FetchRegularFeed)
    @podcast = Factory.create(:podcast, :feeds => [@qf.feed])
    @feed = @podcast.feeds.first
  end

  describe 'with normal RSS feed' do
    it 'should save the error that the feed is not for a podcast' do
      mod_and_run_feed_processor(@qf, FetchRegularFeed)

      @qf.error.should == "FeedProcessor::NoEnclosureException"
    end
  end

  describe "with a site on the blacklist" do
    it 'should save the error that the site is on the blacklist' do
      Blacklist.create!(:domain => "restrictedsite")

      @qf.update_attributes :url => "http://restrictedsite/bad/feed.xml"
      mod_and_run_feed_processor(@qf, FetchRegularFeed)

      @qf.error.should == "FeedProcessor::BannedFeedException"
    end
  end
end

