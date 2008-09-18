require File.dirname(__FILE__) + '/../spec_helper'

describe Comment do
  before do
    @comment = Factory.create(:comment)
    @episode = @comment.episode
    @podcast = @episode.podcast
  end

  it 'should be modifiable if it is on the most recent episode of a podcast.' do
    @comment.should be_editable
  end

  it "shouldn't be modifiable if it is on an episode that isnt most recent." do
    Factory.create(:episode, :podcast => @podcast)

    # Original comment
    @comment.should_not be_editable
  end
end

