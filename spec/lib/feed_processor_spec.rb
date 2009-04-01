require File.dirname(__FILE__) + '/../spec_helper'

module StopDownloadLogo
  def download_logo(*args); end
end
module StopFetch
  def fetch
  end
end

class FeedProcessor
  def fetch
    File.open("#{RAILS_ROOT}/spec/data/example.xml").read
  end
end
class Podcast
  def download_log(*args); end
end

# Feed is not in the system, creating it by url.
describe FeedProcessor, "being parsed" do

  before do
    @qf = QueuedFeed.create(:url => "http://google.com/rss.xml")
     FeedProcessor.new(@qf)
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

  it 'should add tags' do
    @feed.podcast.tag_string.should include('technology', 'gadgets', 'tvandfilm')
    @feed.podcast.tags.size.should == 3
    @feed.podcast.taggers.should include(@feed.podcast.owner)
  end

#  describe "when the submitting user is the podcast owner" do
#    it 'should associate the podcast with the user as owner' do
#      user = Factory.create(:user, :email => "john.doe@example.com")
#      @podcast = Factory.create(:parsed_podcast, :site => "http://www.example.com/")
#      @feed = @podcast.feeds.first
#      @feed.finder = user
#
#      @feed = FeedProcessor.new(@feed.url)
#
#      @feed.reload.finder.should == user
#      @feed.podcast.should be_kind_of(Podcast)
#      @feed.podcast.owner.should == user
#    end
#  end
end

# Feed is already in the system, looking it up by url.
describe FeedProcessor, "being reparsed" do
  before do
    @qf = Factory.create(:queued_feed)

    FeedProcessor.new(@qf)

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
end

describe Feed, "updating episodes" do
  before do
    @qf = Factory.create(:queued_feed)

    FeedProcessor.new(@qf)

    @feed = @qf.feed
  end

  it 'should create some episodes' do
    @feed.podcast.episodes(true).count.should == 3
  end

  it 'should not duplicate episodes that already exist' do
    @feed.podcast.episodes(true).count.should == 3

    FeedProcessor.new(@qf)

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
    lambda { FeedProcessor.new(@qf) }.should change { ActionMailer::Base.deliveries.size }.by(1)
    ActionMailer::Base.deliveries.last.to_addrs.to_s.should == @podcast.editors.map(&:email).join(',')
    ActionMailer::Base.deliveries.last.body.should =~ /A podcast that you can edit has been updated because one of its feeds was changed/
    ActionMailer::Base.deliveries.last.body.should =~ /The Original Title was changed to All About Everything/
    reset_actionmailer
  end
end

describe Feed, "being created" do
  before do
    class FeedProcessor
      def fetch
        File.open("#{RAILS_ROOT}/spec/data/regularfeed.xml").read
      end
    end

    @qf = Factory.create :queued_feed
    @podcast = Factory.create(:podcast, :feeds => [@qf.feed])
    @feed = @podcast.feeds.first
  end

  describe 'with normal RSS feed' do
    it 'should save the error that the feed is not for a podcast' do
      FeedProcessor.new(@qf)

      @qf.error.should == "FeedProcessor::NoEnclosureException"
    end
  end

#   describe "when a weird server error occurs" do
#     it 'should save the error that an unknown exception occurred' do
#       FeedProcessor.new('http://localhost:7')
# 
#       @feed.reload.error.should == "Errno::ECONNREFUSED"
#     end
#   end

  describe "with a site on the blacklist" do
    it 'should save the error that the site is on the blacklist' do
      Blacklist.create!(:domain => "restrictedsite")

      @qf.update_attributes :url => "http://restrictedsite/bad/feed.xml"
      FeedProcessor.new(@qf)

      @qf.error.should == "FeedProcessor::BannedFeedException"
    end
  end
end
# 
#   describe "when it is associated with a podcast that it does not belong to" do
#     it "should save the error that the feed is mismatched" do
#       @feed = Factory.create(:feed, :url => "http://badmatch.com/")
#       @feed.podcast = @podcast
# 
#       @feed.extend(StopFetch)
#       @feed.podcast.extend(StopDownloadLogo)
#       @feed.refresh
# 
#       @feed.error.should == "Feed::FeedDoesNotMatchPodcast"
#     end
#   end
# 
#   describe "when it is added to a podcast that it does not belong to" do
#     it "should add an error to the feed" do
#       @feed = @podcast.feeds.new(:url => 'http://badmatch.com/')
# 
#       @feed.should_not be_valid
#       @feed.errors.on(:url).should include("doesn't seem to match the podcast.")
#     end
#   end
# 
#   describe "but failing to be parsed" do
#     it "should delete the Podcast" do
#       @feed.update_attributes(:state => 'failed')
#       @feed.reload
#       @feed.podcast.should be_nil
#     end
# 
#     it "should not delete the Podcast if it has parsed feeds" do
#       @podcast.feeds << Factory.create(:feed, :state => 'parsed')
#       @feed.update_attributes(:state => 'failed')
#       @feed.reload
#       @feed.podcast.should_not be_nil
#     end
#   end
# end
# 
# describe Feed, "comparing to a podcast" do
#   before do
#     @podcast = Factory.create(:parsed_podcast)
#     @feed = @podcast.feeds.first
#   end
# 
#   describe "based on site url" do
#     before do
#       @feed.extend(StopFetch)
#       @feed.podcast.extend(StopDownloadLogo)
#     end
# 
#     it 'should match a similar podcast' do
#       @podcast.site = "http://www.example.com"
#       @feed.similar_to_podcast?(@podcast).should == true
#     end
#     it 'should not match a different podcast' do
#       @podcast.site = "http://bad-site/blah/foo"
#       @feed.similar_to_podcast?(@podcast).should == false
#     end
#   end
# end
# 
# describe Feed, "changing" do
#   before do
#     @user = Factory.create(:user)
#     @podcast = Factory.create(:parsed_podcast)
#     @feed = @podcast.feeds.first
#     @feed.update_attribute :finder, @user
#     @user.calculate_score!
#   end
# 
#   describe "by destroying it" do
#     it 'should recalculate the finder\'s score' do
#       lambda { @feed.destroy }.should change { @user.score }.by(-1)
#     end
#   end
# end
