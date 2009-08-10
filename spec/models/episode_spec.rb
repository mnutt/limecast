require File.dirname(__FILE__) + '/../spec_helper'

describe Episode do
  before(:each) do
    @episode = Factory.create(:episode)
  end

  it "should be valid" do
    @episode.should be_valid
  end

  it 'should have a thumbnail' do
    @file = PaperClipFile.new
    @file.to_tempfile = Tempfile.new('tmp')
    @episode.attachment_for(:thumbnail).assign(@file)
    @episode.thumbnail.should_not be_nil
  end
end

describe Episode, "finding episodes for a podcast" do
  before(:each) do
    @podcast = Factory.create(:podcast)
    @first =  Factory.create(:episode, :podcast_id => @podcast.id, :published_at => 2.days.ago)
    @second = Factory.create(:episode, :podcast_id => @podcast.id, :published_at => 1.day.ago)
  end

  it 'should list the most recent episode first' do
    @podcast.episodes.find(:all, :order => "published_at DESC").should == [@second, @first]
  end
end

describe Episode, "generating a URL" do
  before(:each) do
    Episode.destroy_all
    @episode = Factory.create(:episode)
  end

  it 'should generate a URL from the published date' do
    @episode.clean_url.should == "2008-Aug-1"
  end

  it 'should generate a URL with a 2 if it has a daily order of 2' do
    e = Factory.build(:episode, :podcast => @episode.podcast, :daily_order => 2)
    e.clean_url.should == "2008-Aug-1-2"
  end

  it 'should generate a URL with a 3 if it has a daily order of 3' do
    e = Factory.build(:episode, :podcast => @episode.podcast, :daily_order => 3)
    e.clean_url.should == "2008-Aug-1-3"
  end
end

describe Episode, "generating a date title" do
  before(:each) do
    @episode = Factory.create(:episode)
  end

  it 'should generate a date title from the published date' do
    @episode.date_title.should == "2008 Aug 1"
  end

  it 'should generate a date title with a 2 if it has a daily order of 2' do
    e = Factory.build(:episode, :podcast => @episode.podcast, :daily_order => 2)
    e.date_title.should == "2008 Aug 1 (2)"
  end

  it 'should generate a date title with a 3 if it has a daily order of 3' do
    e = Factory.build(:episode, :podcast => @episode.podcast, :daily_order => 3)
    e.date_title.should == "2008 Aug 1 (3)"
  end
end

