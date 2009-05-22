require File.dirname(__FILE__) + '/../spec_helper'

# Podcast is not in the system, creating it by url.
describe PodcastProcessor, "being parsed" do

  before do
    @qf = QueuedFeed.create(:url => "http://google.com/rss.xml")
    lambda { mod_and_run_podcast_processor(@qf, FetchExample) }.should change { Podcast.count }.by(1)
    @podcast = @qf.podcast
  end

  it 'should set the title of the podcast' do
    @podcast.reload.title.should == "All About Everything"
  end

  it 'should set the site link of the podcast' do
    @podcast.reload.site.should == "http://www.example.com/podcasts/everything/index.html"
  end

  it 'should set the description of the podcast' do
    @podcast.reload.description.should =~ /^All About Everything is a show about everything/
  end

  it 'should set the language of the podcast' do
    @podcast.reload.language.should == "en-us"
  end

  it 'should set the generator of the podcast' do
    @podcast.reload.generator.should == "http://limecast.com/tracker"
  end

  it 'should add tags' do
    @podcast.tag_string.should include('technology', 'gadgets', 'tvandfilm')
    @podcast.tags.size.should == 3
    @podcast.taggers.should include(@podcast.owner)
  end

  it 'should associate the podcast with the user as owner' do
    User.destroy_all

    user = Factory.create(:user, :email => "john.doe@example.com")
    @podcast = Factory.create(:podcast, :site => "http://www.example.com/")

    @qf = QueuedFeed.create(:url => @podcast.url, :podcast_id => @podcast.id, :user => user)
    mod_and_run_podcast_processor(@qf, FetchExample)

    @podcast.reload.finder.should == user
    @podcast.should be_kind_of(Podcast)
    @podcast.owner.should == user
  end
end

describe PodcastProcessor, "failing" do
  before do
    @qf = QueuedFeed.create(:url => "http://google.com/rss.xml")
    mod_and_run_podcast_processor(@qf, FetchRegularFeed)
  end

  it 'should not create a Feed' do
    PodcastProcessor.process(@qf)

    @qf.podcast.should be_nil
  end
end


# Feed is already in the system, looking it up by url.
describe PodcastProcessor, "being reparsed" do
  before do
    @qf = Factory.create(:queued_feed)
    mod_and_run_podcast_processor(@qf, FetchExample)
    @podcast = @qf.podcast
  end

  it 'should set the title of the podcast' do
    @podcast.reload.xml_title.should == "All About Everything"
  end

  it 'should set the site link of the podcast' do
    @podcast.reload.site.should == "http://www.example.com/podcasts/everything/index.html"
  end

  it 'should set the description of the podcast' do
    @podcast.reload.description.should =~ /^All About Everything is a show about everything/
  end

  it 'should set the language of the podcast' do
    @podcast.reload.language.should == "en-us"
  end

  it 'should set the generator of the podcast' do
    @podcast.reload.generator.should == "http://limecast.com/tracker"
  end
end

describe PodcastProcessor, "parsing a podcast's second feed" do
  before do
    @qf = Factory.create(:queued_feed)
    mod_and_run_podcast_processor(@qf, FetchExample)
    @podcast = @qf.podcast.reload
    @qf2 = QueuedFeed.create(:url => (@qf.url.split('/')[0..-2].join+'feed_two.xml'))
  end

  it 'should not change the podcast' do
    lambda { mod_and_run_podcast_processor(@qf2, FetchExample) }.should_not change { @podcast.reload.updated_at}
  end

  it 'should increment podcasts' do
    lambda { mod_and_run_podcast_processor(@qf2, FetchExample) }.should change(Podcast, :count).by(1)
  end
end

describe Podcast, "updating episodes" do
  before do
    @qf = Factory.create(:queued_feed)
    mod_and_run_podcast_processor(@qf, FetchExampleWithMRSS)
    @podcast = @qf.podcast
  end

  it 'should create some episodes' do
    @podcast.episodes(true).count.should == 3
  end

  it 'should not duplicate episodes that already exist' do
    @podcast.episodes(true).count.should == 3
    mod_and_run_podcast_processor(@qf, FetchExampleWithMRSS)
    @podcast.episodes(true).count.should == 3
  end
  
  it 'should create 4 sources for any given episode (from enclosure + mrss)' do
    @podcast.episodes[0].sources.count.should == 4
  end

  it 'should create sources with the proper urls (from enclosure + mrss)' do
    @podcast.episodes[0].sources.map(&:url).should == [
      "http://example.com/podcasts/everything/AllAboutEverythingEpisode3.m4a",
      "http://example.com/podcasts/everything/AllAboutEverythingEpisode3.mov",
      "http://example.com/podcasts/everything/AllAboutEverythingEpisode3.flv",
      "http://example.com/podcasts/everything/AllAboutEverythingEpisode3.m4v"
      ]
  end

  it 'should create sources with the proper format (from enclosure + mrss)' do
    @podcast.episodes[0].sources.map(&:format).should == ['m4a', 'mov', 'flv', 'm4v']
  end

  it 'should create sources with the proper sizes (from enclosure + mrss)' do
    @podcast.episodes[0].sources.map(&:size).should == [8727310, 767302043, 18320136, 57167895]
  end
end

describe Podcast, "downloading the logo for its podcast" do
  before do
    @podcast = Factory.create(:podcast)
  end

  it 'should not set the logo_filename for a bad link' do
    @podcast.download_logo('http://google.com')
    @podcast.logo_file_name.should be_nil
  end
end


describe Podcast, "when a weird server error occurs" do
  before do
    @podcast = Factory.create(:podcast)
    @qf = Factory.create :queued_feed, :url => 'http://localhost:7', :podcast_id => @podcast
  end

  it 'should save the error that an unknown exception occurred' do
    PodcastProcessor.process(@qf)

    @qf.error.should == "Errno::ECONNREFUSED"
  end
end

describe Podcast, "being created" do
  before do
    @qf = Factory.create :queued_feed
    mod_and_run_podcast_processor(@qf, FetchRegularFeed)
    @podcast = Factory.create(:podcast)
  end

  describe 'with normal RSS feed' do
    it 'should save the error that the feed is not for a podcast' do
      mod_and_run_podcast_processor(@qf, FetchRegularFeed)

      @qf.error.should == "PodcastProcessor::NoEnclosureException"
    end
  end

  describe "with a site on the blacklist" do
    it 'should save the error that the site is on the blacklist' do
      Blacklist.create!(:domain => "restrictedsite")

      @qf.update_attributes :url => "http://restrictedsite/bad/feed.xml"
      mod_and_run_podcast_processor(@qf, FetchRegularFeed)

      @qf.error.should == "PodcastProcessor::BannedFeedException"
    end
  end
end

