require File.dirname(__FILE__) + '/../spec_helper'

describe Review do
  before do
    @review = Factory.create(:review)
    @episode = @review.episode
    @podcast = @episode.podcast
  end

  it 'should be modifiable if it is on the most recent episode of a podcast.' do
    @review.should be_editable
  end

  it "shouldn't be modifiable if it is on an episode that isnt most recent." do
    Factory.create(:episode, :podcast => @podcast, :published_at => 20.days.from_now)

    # Original review
    @review.should_not be_editable
  end

  it 'should not be valid if there is no reviewer' do
    Factory.build(:review, :reviewer => nil).should_not be_valid
  end

  it 'should not be able to be rated multiple times by the same person' do
    tmp_user = Factory.create(:user)
    tmp_user_adds_rating_to_review = lambda { @review.comment_ratings << CommentRating.new(:user => tmp_user) }

    tmp_user_adds_rating_to_review.should     change { @review.comment_ratings.count }.by(1)
    tmp_user_adds_rating_to_review.should_not change { @review.comment_ratings.count }
  end

  it 'should be able to be rated if the user had not rated the review before' do
    new_user_adds_rating_to_review = lambda { @review.comment_ratings << CommentRating.new(:user => Factory.create(:user)) }
    5.times do
      new_user_adds_rating_to_review.should change { @review.comment_ratings.count }.by(1)
    end
  end

  it 'should not be able to be rated by the author' do
    lambda {
      @review.comment_ratings << CommentRating.new(:user => @review.reviewer)
    }.should_not change { @review.comment_ratings.count }
  end
end

