require File.dirname(__FILE__) + '/../spec_helper'

describe ReviewRating, "being claimed" do
  before do
    @review = Factory.create(:review)
    @review_rating = Factory.create(:review_rating, :user => nil)
    @user = Factory.create(:user)
  end

  it "should set the user_id to the one given" do
    lambda { @review_rating.claim_by(@user) }.should change { @review_rating.user_id }
    @review_rating.reload.user_id.should be(@user.id)
  end
end
