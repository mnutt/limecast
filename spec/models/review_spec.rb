require File.dirname(__FILE__) + '/../spec_helper'

describe Review do
  before do
    @review = Factory.create(:review)
    @podcast = @review.podcast
  end

  it 'should not be able to be rated multiple times by the same person' do
    tmp_user = Factory.create(:user)
    tmp_user_adds_rating_to_review = lambda { @review.review_ratings << ReviewRating.new(:user => tmp_user) }

    tmp_user_adds_rating_to_review.should     change { @review.review_ratings.count }.by(1)
    tmp_user_adds_rating_to_review.should_not change { @review.review_ratings.count }
  end

  it 'should be able to be rated if the user had not rated the review before' do
    new_user_adds_rating_to_review = lambda { @review.review_ratings << ReviewRating.new(:user => Factory.create(:user)) }
    5.times do
      new_user_adds_rating_to_review.should change { @review.review_ratings.count }.by(1)
    end
  end

  it 'should not be able to be rated by the author' do
    lambda {
      @review.review_ratings << ReviewRating.new(:user => @review.reviewer)
    }.should_not change { @review.review_ratings.count }
  end

  it 'should be writable by the reviewer' do
    @review.should be_writable_by(@review.reviewer)
  end

  it 'should not be writable by a different user' do
    @review.should_not be_writable_by(Factory.create(:user))
  end

  it 'should be writable by god users' do
    @review.should be_writable_by(Factory.create(:admin_user))
  end
end

describe Review, "being claimed" do
  before do
    @review = Factory.create(:review, :user_id => nil)
    @user = Factory.create(:user)
  end

  it "should set the user_id to the one given" do
    lambda { @review.claim_by(@user) }.should change { @review.user_id }
    @review.reload.user_id.should be(@user.id)
  end
end
