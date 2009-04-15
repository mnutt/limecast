require File.dirname(__FILE__) + '/../spec_helper'

describe ReviewsController do
  before(:each) do
    @user = Factory.create(:user)
    @podcast = Factory.create(:podcast)
    @episode = Factory.create(:episode, :podcast => @podcast)
    @review = Factory.create(:review, :reviewer => @user, :episode => @episode)
    login(@user)
  end

  describe "handling GET /:podcast_slug/reviews" do
    def do_get(podcast)
      get :index, :podcast_slug => podcast
    end

    it "should be successful" do
      do_get(@podcast.clean_url)
      response.should redirect_to(podcast_url(@podcast))
    end
  end

  describe "handling POST /:podcast_slug/reviews" do
    def do_put
      put :create, :podcast_slug => @podcast.clean_url, :review => { :title => 'new', :body => 'review', :episode_id => @episode.id }
    end

    it "should update the review" do
      lambda { do_put }.should change { @podcast.reviews(true).count }.by(1)
      assigns(:review).title.should == 'new'
      assigns(:review).body.should == 'review'
    end

    describe "when logged out" do
      before(:each) { logout }

      it "should add unclaimed review" do
        lambda { do_put }.should change { Review.unclaimed.count }.by(1)
        assigns(:review).reviewer.should be_nil
      end

      it "should add the unclaimed review to the session" do
        do_put
        session[:unclaimed_records]['Review'].should include(assigns(:review).id)
      end

      it "should only be able to be reviewed one by a user" do
        @podcast = Factory.create(:podcast)
        @episode = Factory.create(:episode, :podcast => @podcast)
        review = Factory.create(:review, :reviewer => nil, :episode => @episode)
        @controller.send(:remember_unclaimed_record, review)

        lambda { do_put }.should_not change { Review.count }
        assigns[:review].should be_nil
      end
    end
  end

  describe "handling PUT /:podcast_slug/reviews/1" do
    def do_put(review)
      put :update, :podcast_slug => @podcast.clean_url, :id => review.id, :review => { :title => 'newish' }
    end

    it "should update the review" do
      request.env["HTTP_REFERER"] = "http://www.google.com"
      do_put(@review)
      @review.reload.title.should eql("newish")
    end
  end

  describe "handling DESTROY /:podcast_slug/reviews/1" do
    def do_destroy(review)
      delete :destroy, :podcast_slug => @podcast.clean_url, :id => review.id
    end

    it "should be successful" do
      do_destroy(@review)
      response.should be_success
    end

    it "should delete the review" do
      lambda { do_destroy(@review) }.should change { @podcast.reviews.count }.by(-1)
    end
  end

  describe 'rating a review' do
    before do
      @other_user = Factory.create(:user)
      login @other_user
    end

    def do_get(review, rating)
      request.env['HTTP_REFERER'] = ""
      get :rate, :podcast_slug => @podcast.clean_url, :id => review.id, :rating => rating
    end

    it 'should only be able to be reviewed one by a user' do
      rate_review = lambda { do_get(@review, 'insightful') }

      rate_review.should     change { @review.insightful }.by(1)
      rate_review.should_not change { @review.insightful }
    end

    it 'should up the insightful ratings if a review is rated as insightful' do
      lambda { do_get(@review, 'insightful') }.should change { @review.insightful }.by(1)
    end

    it 'should up the not_insightful ratings if a review is rated as not_insightful' do
      lambda { do_get(@review, 'not_insightful') }.should change { @review.not_insightful }.by(1)
    end

    describe "when logged out" do
      before(:each) { logout }

      it "should add unclaimed review" do
        lambda { do_get(@review, 'insightful') }.should change { ReviewRating.unclaimed.count }.by(1)
        assigns[:rating].user.should be_nil
      end

      it "should add the unclaimed review to the session" do
        do_get(@review, 'insightful')
        session[:unclaimed_records]['ReviewRating'].should include(assigns[:rating].id)
        @controller.send(:remember_unclaimed_record, @review)
      end

      it "should only be able to be reviewed one by a user" do
        review_rating = Factory.create(:review_rating, :review => @review, :user => nil)
        @controller.send(:remember_unclaimed_record, review_rating)

        lambda { do_get(@review, 'insightful') }.should_not change { ReviewRating.count }
        assigns[:rating].should be_nil
      end
    end

  end
end
