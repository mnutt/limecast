require File.dirname(__FILE__) + '/../spec_helper'

describe Podcast do
  before do
    @podcast = Factory.create(:podcast)
    @user    = Factory.create(:user)
  end

  it "should be valid" do
    @podcast.should be_valid
  end

  it 'should have a logo' do
    @file = PaperClipFile.new
    @podcast.attachment_for(:logo).assign(@file)
    @podcast.logo.should_not be_nil
  end

  it 'should be taggable' do
    @podcast.tag_list = "hi"
    @podcast.save
    @podcast.tags.size.should == 1
  end

  it 'should have a param with the name in it' do
    @podcast.state = 'parsed'
    @podcast.sanitize_url
    @podcast.clean_url.should == "Podcast"
  end
end

describe Podcast, "creating a new podcast" do
  before do
    @podcast = Podcast.create!(:feed_url => "http://defaultfeed/index.rss")
  end

  it 'should be pending' do
    @podcast.state.should == "pending"
  end
end

describe Podcast, "fetching a podcast" do
  before do
    @podcast = Factory.create(:podcast)
    @podcast.state = "pending"
  end

  it 'should call retrieve_feed with the feed_url' do
    Podcast.should_receive(:retrieve_feed).with(@podcast.feed_url)
    @podcast.fetch!
  end

  it 'should populate the feed_content field' do
    content = File.open("#{RAILS_ROOT}/spec/data/example.xml").read
    Podcast.stub!(:retrieve_feed).and_return(content)
    @podcast.fetch!
    @podcast.feed_content.should =~ /^\<\?xml version/
    @podcast.feed_content.size.should == 3243
  end
end

describe Podcast, "parsing a podcast" do

  before do
    @podcast = Factory.create(:fetched_podcast)
    @podcast.parse_feed
  end

  it 'should set the feed url' do
    @podcast.reload.feed_url.should == "http://fetchedpodcast/feed.xml"
  end

  it 'should extract the title' do
    # raise @podcast.to_yaml
    @podcast.reload.title.should == "All About Everything"
  end

  it 'should extract the site link' do
    @podcast.reload.site.should == "http://www.example.com/podcasts/everything/index.html"
  end

  it 'should extract the logo link' do
    @podcast.reload.logo_link.should == "http://summitviewcc.com/picts/PodcastLogo.png"
  end
 
  it 'should extract the description' do
    @podcast.reload.description.should =~ /^All About Everything is a show about everything/
  end

  it 'should extract the language' do
    @podcast.reload.language.should == "en-us"
  end
end

describe Podcast, "finding a podcast" do
  before do
    @podcast         = Factory.create(:podcast)
    @fetched_podcast = Factory.create(:fetched_podcast)
    @fetched_podcast.reload.state.should == "fetched"
    @parsed_podcast  = Factory.create(:parsed_podcast)
    @parsed_podcast.reload.state.should == "parsed"

    @all     = Podcast.all
    @fetched = Podcast.fetched.all
    @parsed  = Podcast.parsed.all
  end

  it 'should be able to find all 3 podcasts with a call to "all"' do
    @all.should be_an(Array)
    @all.length.should == 3
    [@podcast, @fetched_podcast, @parsed_podcast].each {|p| @all.includes?(p).should be_true }
  end

  it 'should be able to find just 1 podcast with a call to "fetched"' do
    @fetched.should be_an(Array)
    @fetched.length.should == 1
    [@fetched_podcast].each {|p| @fetched.include?(p).should be_true }
  end

  it 'should be able to find just 1 podcast with a call to "parsed"' do
    @parsed.should be_an(Array)
    @parsed.length.should == 1
    [@parsed_podcast].each {|p| @parsed.include?(p).should be_true }
  end
end

describe Podcast, "downloading the logo" do
  before do
    @podcast = Factory.create(:parsed_podcast)
    @podcast.logo_link = "http://badlink/"
  end

  it 'should not set the logo_filename for a bad link' do
    lambda {
      @podcast.download_logo
    }.should raise_error(SocketError)
    @podcast.logo_file_name.should be_nil
  end
end

# 
# # describe Podcast, "creating a new podcast when the user is not the feed owner" do
# #   it 'should set the user as the finder'
# #   it 'should not set the user as the owner'
# # end
# 
# # describe Podcast, "creating a new podcast when the user is the feed owner" do
# #   it 'should set the user as the finder'
# #   it 'should set the user as the owner'
# # end
# 
# # describe Podcast, "creating a new podcast when the user is not logged in" do
# #   it 'should not set the user as the finder'
# 
# #   it 'should not set the user as the owner'
# # end
# 
# describe Podcast, "creating a new podcast with a non-existant URL" do
#   it 'should raise an error that the URL is not contactable' do
#     pending "figure out how to make it timeout without waiting"
#     podcast = Podcast.create!(:feed_url => "http://192.168.219.47", :state => "pending")
#     podcast.feed_error.should == "The server was not contactable."
#   end
# end
# 
# describe Podcast, "creating a new podcast with an RSS feed that is not a podcast" do
#   it 'should raise an error that the feed is not a podcast' do
#     mock_feed("#{RAILS_ROOT}/spec/data/regularfeed.xml")
#     podcast = Podcast.create!(:feed_url => "http://regularfeed/", :state => "pending")
#     podcast.feed_error.should == "This is not a podcast feed. Try again."
#   end
# end
# 
# describe Podcast, "creating a new podcast with a non-URL string" do
#   it 'should raise an error that the feed is not a URL' do
#     podcast = Podcast.create!(:feed_url => "localhost", :state => "pending")
#     podcast.feed_error.should == "That's not a web address. Try again."
#   end
# end
# 
# describe Podcast, "creating a new podcast when a weird server error occurs" do
#   it 'should raise an error that an unknown exception occurred' do
#     podcast = Podcast.create!(:feed_url => "http://localhost:7/", :state => "pending")
#     podcast.feed_error.should == "Weird server error. Try again."
#   end
# end
# 
# describe Podcast, "creating a new podcast that is from a site on the blacklist" do
#   it 'should raise an error that the site is on the blacklist' do
#     Blacklist.create!(:domain => "restrictedsite")
#     podcast = Podcast.create!(:feed_url => "http://restrictedsite/bad/feed.xml", :state => "pending")
#   end
# end
# 
# describe Podcast, "creating a new podcast that already exists in the system" do
#   it 'should raise an error that the podcast has already been registered' do
#     mock_feed("#{RAILS_ROOT}/spec/data/example.xml")
#     @podcast = Podcast.new(:feed_url => "#{RAILS_ROOT}/spec/data/example.xml", :state => "pending")
#     @podcast.save
#     @podcast = Podcast.new(:feed_url => "#{RAILS_ROOT}/spec/data/example.xml", :state => "pending")
#     @podcast.save.should be_false
#   end
# end
# 
# def mock_feed(path)
#   feed = File.read(path)
#   Podcast.stub!(:retrieve_feed).and_return(feed)
# end
# 
# describe Podcast, "cleaning up the site url" do
#   before do
#     @podcast = Podcast.new(:state => "parsed")
#   end
#   
#   it 'should remove a leading http://' do
#     @podcast.site = "http://test.host"
#     @podcast.clean_site.should == "test.host"
#   end
# 
#   it 'should remove a leading www.' do
#     @podcast.site = "www.test.host"
#     @podcast.clean_site.should == "test.host"
#   end
# 
#   it 'should remove both a leading http and www' do
#     @podcast.site = "http://www.test.host"
#     @podcast.clean_site.should == "test.host"
#   end
# 
#   it 'should remove a trailing slash' do
#     @podcast.site = "http://test.host/"
#     @podcast.clean_site.should == "test.host"
#   end
# 
#   it 'should allow for a path' do
#     @podcast.site = "http://test.host/path/to/page"
#     @podcast.clean_site.should == "test.host/path/to/page"
#   end
# 
#   it 'should not modify a non-url' do
#     @podcast.site = "test.host"
#     @podcast.clean_site.should == "test.host"
#   end
# end
# 
# describe Podcast, "generating the clean title url" do
#   before do
#     @podcast = Podcast.new(:state => "parsed")
#   end
# 
#   it 'should remove leading and trailing whitespaces' do
#     @podcast.title = ' title '
#     @podcast.generate_url.should == 'title'
#   end
# 
#   it 'should remove non-alphanumeric characters' do
#     @podcast.title = ' ^$(title '
#     @podcast.generate_url.should == 'title'
#   end
# 
#   it 'should convert interior spaces to dashes' do
#     @podcast.title = ' my $title '
#     @podcast.generate_url.should == 'my-title'
#   end
# end
