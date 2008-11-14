require File.dirname(__FILE__) + '/../spec_helper'

describe ReviewsController do
  before(:each) do
    @user = Factory.create(:user)
    @podcast = Factory.create(:podcast)
    @episode = Factory.create(:episode, :podcast => @podcast)
    @review = Factory.create(:review, :reviewer => @user, :episode => @episode)
    login(@user)
  end

  describe "handling POST /:podcast/reviews/1" do
    def do_post(review)
      put :update, :podcast => @podcast.clean_url, :id => review.id, :review => { :title => 'newish' }
    end

    it "should redirect" do
      do_post(@review)
      response.should redirect_to(review_url(:podcast => @podcast, :id => @review.id))
    end

    it "should update the review" do
      do_post(@review)
      @review.reload.title.should eql("newish")
    end
  end

  describe "handling DESTROY /:podcast/reviews/1" do
    def do_destroy(review)
      delete :destroy, :podcast => @podcast.clean_url, :id => review.id
    end

    it "should be successful" do
      do_destroy(@review)
      response.should be_success
    end

    it "should delete the review" do
      lambda { do_destroy(@review) }.should change { @podcast.reviews.count }.by(-1)
    end
  end
end
