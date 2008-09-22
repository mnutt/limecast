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
    @podcast.generate_url
    @podcast.clean_title.should == "Podcast"
  end
end

# 
# describe Podcast, "creating a new podcast" do
#   before do
#     @podcast = Podcast.create(:feed_url => "http://defaultfeed/index.rss")
#   end
# 
#   it 'should be pending' do
#     @podcast.state.should == "pending"
#   end
# end
# 
# describe Podcast, "creating a new podcast" do
# 
#   before do
#     mock_feed("#{RAILS_ROOT}/spec/data/example.xml")
# 
#     @podcast = Podcast.create!(:feed_url => "http://defaultfeed/")
#   end
# 
#   it 'should set the feed url' do
#     @podcast.reload.feed_url.should == "http://defaultfeed/"
#   end
# 
#   it 'should extract the title' do
#     # raise @podcast.to_yaml
#     @podcast.reload.title.should == "All About Everything"
#   end
# 
#   it 'should extract the site link' do
#     @podcast.reload.site.should == "http://www.example.com/podcasts/everything/index.html"
#   end
# 
#   it 'should extract the logo link' do
#     @podcast.reload.logo_link.should == "http://summitviewcc.com/picts/PodcastLogo.png"
#   end
#  
#   it 'should extract the description' do
#     @podcast.reload.description.should =~ /^All About Everything is a show about everything/
#   end
# 
#   it 'should extract the language' do
#     @podcast.reload.language.should == "en-us"
#   end
# end
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
