require File.dirname(__FILE__) + '/../spec_helper'

describe Podcast do
  before(:each) do
    @podcast = Podcast.new
  end

  it "should be valid" do
    @podcast.should be_valid
  end

  it 'should have a logo'
  it 'should be taggable'
  it 'should have a param with the name in it'
end

describe Podcast, "creating a new podcast from feed" do
  it 'should set the feed url'
  it 'should extract the title'
  it 'should extract the site link'
  it 'should extract the logo link'
  it 'should extract the description'
  it 'should extract the language'
end

describe Podcast, "saving a podcast" do
  it 'should retrieve episodes from the feed'
  it 'should download the logo if a link is provided'
end
