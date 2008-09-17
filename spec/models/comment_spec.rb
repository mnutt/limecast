require File.dirname(__FILE__) + '/../spec_helper'

describe Comment do
  it 'should not be editable if there are comments on the same object that are older than this' do
    @episode = Factory(:episode)
    @comments = []

    @comments << Factory(:episode_comment, :episode => @episode)
    @comments[0].should be_editable

    @comments << Factory(:episode_comment, :episode => @episode, :created_at => 10.minutes.from_now)
    @comments[0].should_not be_editable
    @comments[1].should be_editable

    @comments << Factory(:episode_comment, :episode => @episode, :created_at => 20.minutes.from_now)
    @comments[0].should_not be_editable
    @comments[1].should_not be_editable
    @comments[2].should be_editable
  end
end

