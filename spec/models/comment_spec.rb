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
    Factory.create(:episode, :podcast => @podcast, :published_at => 20.days.from_now)

    # Original comment
    @comment.should_not be_editable
  end

  it 'should not be valid if there is no commenter' do
    Factory.build(:comment, :commenter => nil).should_not be_valid
  end

  it 'should not be able to be rated multiple times by the same person' do
    tmp_user = Factory.create(:user)
    tmp_user_adds_rating_to_comment = lambda { @comment.comment_ratings << CommentRating.new(:user => tmp_user) }

    tmp_user_adds_rating_to_comment.should     change { @comment.comment_ratings.count }.by(1)
    tmp_user_adds_rating_to_comment.should_not change { @comment.comment_ratings.count }
  end

  it 'should be able to be rated if the user had not rated the comment before' do
    new_user_adds_rating_to_comment = lambda { @comment.comment_ratings << CommentRating.new(:user => Factory.create(:user)) }
    5.times do
      new_user_adds_rating_to_comment.should change { @comment.comment_ratings.count }.by(1)
    end
  end

  it 'should not be able to be rated by the author' do
    lambda {
      @comment.comment_ratings << CommentRating.new(:user => @comment.commenter)
    }.should_not change { @comment.comment_ratings.count }
  end
end

