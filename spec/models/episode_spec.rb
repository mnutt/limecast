require File.dirname(__FILE__) + '/../spec_helper'

describe Episode do
  before do
    @episode = Factory.create(:episode)
    @user    = Factory.create(:user)
  end

  it 'should not have been_reviewed_by? a user if the episode has no comments' do
    @episode.been_reviewed_by?(@user).should be_false
  end

  it 'should have been_reviewed_by? a user if they commented on an episode' do
    Factory.create(:episode_comment, :commentable => @episode, :commenter => @user)
    @episode.been_reviewed_by?(@user).should be_true
  end

  it 'should not have_been_reviewed_by? a nil user' do
    @episode.been_reviewed_by?(nil).should be_false
  end
end

describe Episode do
  before(:each) do
    @episode = Factory.create(:episode)
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
    @episode = Factory.create(:episode)
  end

  it 'should generate a URL from the published date' do
    @episode.generate_url.should == "2008-Aug-1"
  end

  it 'should generate a URL with an extra number when there is a conflict' do
    e = Factory.create(:episode, :podcast => @episode.podcast)
    e.generate_url.should == "2008-Aug-1-2"
  end

  it 'should generate a URL with an extra number when there are multiple conflicts' do
    Factory.create(:episode, :podcast => @episode.podcast)
    e = Factory.create(:episode, :podcast => @episode.podcast)
    e.generate_url.should == "2008-Aug-1-3"
  end

  it 'should not add an extra number when the conflict is with itself' do
    @episode.save!
    @episode.generate_url.should == "2008-Aug-1"
  end

  it 'should not conflict with other podcasts\' episodes'
end
