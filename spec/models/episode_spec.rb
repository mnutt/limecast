require File.dirname(__FILE__) + '/../spec_helper'

describe Episode do
  before(:each) do
    @episode = Episode.new
  end

  it "should be valid" do
    @episode.should be_valid
  end

  it 'should have a thumbnail' do
    @file = PaperClipFile.new
    @episode.attachment_for(:thumbnail).assign(@file)
    @episode.thumbnail.should_not be_nil
  end
end

describe Episode, "generating a URL" do
  before(:each) do
    @episode = Episode.new(:published_at => Time.parse('Aug 1, 2008'))
  end

  it 'should generate a URL from the published date' do
    @episode.generate_clean_url.should == "2008-Aug-01"
  end

  it 'should generate a URL with an extra number when there is a conflict' do
    Episode.create!(:published_at => Time.parse('Aug 1, 2008'))
    @episode.generate_clean_url.should == "2008-Aug-01-2"
  end

  it 'should generate a URL with an extra number when there are multiple conflicts' do
    Episode.create!(:published_at => Time.parse('Aug 1, 2008'))
    Episode.create!(:published_at => Time.parse('Aug 1, 2008'))
    @episode.generate_clean_url.should == "2008-Aug-01-3"
  end

  it 'should not add an extra number when the conflict is with itself' do
    @episode.save!
    @episode.generate_clean_url.should == "2008-Aug-01"
  end
end
