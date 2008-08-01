require File.dirname(__FILE__) + '/../spec_helper'

describe Podcast do
  before(:each) do
    @podcast = Podcast.new
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
  it 'should set the feed url'
  it 'should extract the title'
  it 'should extract the site link'
  it 'should extract the logo link'
  it 'should extract the description'
  it 'should extract the language'
end

describe Podcast, "creating a new podcast when the user is not the feed owner" do
  it 'should set the user as the finder'
  it 'should not set the user as the owner'
end

describe Podcast, "creating a new podcast when the user is the feed owner" do
  it 'should set the user as the finder'
  it 'should set the user as the owner'
end

describe Podcast, "creating a new podcast when the user is not logged in" do
  it 'should not set the user as the finder'
  it 'should not set the user as the owner'
end

describe Podcast, "creating a new podcast with a non-existant URL" do
  it 'should raise an error that the URL is not contactable'
  it 'should not save the podcast'
end

describe Podcast, "creating a new podcast with an RSS feed that is not a podcast" do
  it 'should raise an error that the feed is not a podcast'
  it 'should not save the podcast'
end

describe Podcast, "creating a new podcast with a non-URL string" do
  it 'should raise an error that the feed is not a URL'
  it 'should not save the podcast'
end

describe Podcast, "creating a new podcast when a weird server error occurs" do
  it 'should raise an error that an unknown exception occurred'
  it 'should not save the podcast'
end

describe Podcast, "creating a new podcast that already exists in the system" do
  it 'should raise an error that the podcast has already been registered'
  it 'should not save the podcast again'
end
