require File.dirname(__FILE__) + '/../spec_helper'

describe Comment do
  it 'should not be editable if there are comments on the same object that are older than this' do
    @podcast = Factory(:podcast)
    @comments = []

    @comments << Factory(:podcast_comment, :commentable => @podcast)
    @comments[0].should be_editable

    @comments << Factory(:podcast_comment, :commentable => @podcast, :created_at => 10.minutes.from_now)
    @comments[0].should_not be_editable
    @comments[1].should be_editable

    @comments << Factory(:podcast_comment, :commentable => @podcast, :created_at => 20.minutes.from_now)
    @comments[0].should_not be_editable
    @comments[1].should_not be_editable
    @comments[2].should be_editable
  end
end

