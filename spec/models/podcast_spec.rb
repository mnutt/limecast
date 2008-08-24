require File.dirname(__FILE__) + '/../spec_helper'

describe Podcast do
  before(:each) do
    mock_feed("#{RAILS_ROOT}/spec/data/example.xml")
    @podcast = Podcast.new
    @podcast.feed = "http://defaultfeed"
    @podcast.title = "My Podcast"
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
    @podcast.save
    @podcast.to_param.should == "My-Podcast"
  end
end

describe Podcast, "creating a new podcast" do

  before do
    mock_feed("#{RAILS_ROOT}/spec/data/example.xml")

    @podcast = Podcast.new_from_feed "http://defaultfeed/"
  end

  it 'should set the feed url' do
    @podcast.feed.should == "http://defaultfeed/"
  end

  it 'should extract the title' do
    @podcast.title.should == "All About Everything"
  end

  it 'should extract the site link' do
    @podcast.site.should == "http://www.example.com/podcasts/everything/index.html"
  end

  it 'should extract the logo link' do
    @podcast.logo_link.should == "http://summitviewcc.com/picts/PodcastLogo.png"
  end
 
  it 'should extract the description' do
    @podcast.description.should =~ /^All About Everything is a show about everything/
  end

  it 'should extract the language' do
    @podcast.language.should == "en-us"
  end
end

# describe Podcast, "creating a new podcast when the user is not the feed owner" do
#   it 'should set the user as the finder'
#   it 'should not set the user as the owner'
# end

# describe Podcast, "creating a new podcast when the user is the feed owner" do
#   it 'should set the user as the finder'
#   it 'should set the user as the owner'
# end

# describe Podcast, "creating a new podcast when the user is not logged in" do
#   it 'should not set the user as the finder'

#   it 'should not set the user as the owner'
# end

describe Podcast, "creating a new podcast with a non-existant URL" do
  it 'should raise an error that the URL is not contactable' do
    pending "figure out how to make it timeout without waiting"
    podcast = Podcast.new_from_feed("http://192.168.219.47")
    podcast.errors["feed"].should == "The server was not contactable."
  end
end

describe Podcast, "creating a new podcast with an RSS feed that is not a podcast" do
  it 'should raise an error that the feed is not a podcast' do
    mock_feed("#{RAILS_ROOT}/spec/data/regularfeed.xml")
    podcast = Podcast.new_from_feed("http://regularfeed/")
    podcast.feed_error.should == "This is not a podcast feed. Try again."
  end
end

describe Podcast, "creating a new podcast with a non-URL string" do
  it 'should raise an error that the feed is not a URL' do
    podcast = Podcast.new_from_feed("localhost")
    podcast.feed_error.should == "That's not a web address. Try again."
  end
end

describe Podcast, "creating a new podcast when a weird server error occurs" do
  it 'should raise an error that an unknown exception occurred' do
    podcast = Podcast.new_from_feed("http://localhost:7/")
    podcast.feed_error.should == "Weird server error. Try again."
  end
end

describe Podcast, "creating a new podcast that is from a site on the blacklist" do
  it 'should raise an error that the site is on the blacklist' do
    Blacklist.create(:domain => "restrictedsite")
    podcast = Podcast.new_from_feed("http://restrictedsite/bad/feed.xml")
  end
end

describe Podcast, "creating a new podcast that already exists in the system" do
  it 'should raise an error that the podcast has already been registered' do
    mock_feed("#{RAILS_ROOT}/spec/data/example.xml")
    @podcast = Podcast.new_from_feed "#{RAILS_ROOT}/spec/data/example.xml"
    @podcast.save
    @podcast = Podcast.new_from_feed "#{RAILS_ROOT}/spec/data/example.xml"
    @podcast.save.should be_false
  end
end

def mock_feed(path)
  feed = File.read(path)
  Podcast.stub!(:retrieve_feed).and_return(feed)
end

describe Podcast, "cleaning up the site url" do
  before do
    @podcast = Podcast.new
  end
  
  it 'should remove a leading http://' do
    @podcast.site = "http://test.host"
    @podcast.clean_site.should == "test.host"
  end

  it 'should remove a trailing slash' do
    @podcast.site = "http://test.host/"
    @podcast.clean_site.should == "test.host"
  end

  it 'should allow for a path' do
    @podcast.site = "http://test.host/path/to/page"
    @podcast.clean_site.should == "test.host/path/to/page"
  end

  it 'should not modify a non-url' do
    @podcast.site = "test.host"
    @podcast.clean_site.should == "test.host"
  end
end

describe Podcast, "generating the clean title url" do
  before do
    @podcast = Podcast.new
  end

  it 'should remove leading and trailing whitespaces' do
    @podcast.title = ' title '
    @podcast.generate_url.should == 'title'
  end

  it 'should remove non-alphanumeric characters' do
    @podcast.title = ' ^$(title '
    @podcast.generate_url.should == 'title'
  end

  it 'should convert interior spaces to dashes' do
    @podcast.title = ' my $title '
    @podcast.generate_url.should == 'my-title'
  end
end
