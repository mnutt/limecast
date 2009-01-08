require File.dirname(__FILE__) + '/../spec_helper'

describe ReviewsController do
  before(:each) do
    @user = Factory.create(:user)
    @podcast = Factory.create(:podcast)
    @episode = Factory.create(:episode, :podcast => @podcast)
    @review = Factory.create(:review, :reviewer => @user, :episode => @episode)
    login(@user)
  end
  
  describe "handling GET /:podcast/reviews/search" do
    before(:each) do
      @user2 = Factory.create(:user)
      @review2 = Factory.create(:review, :reviewer => @user2, :episode => @episode, :body => "blah blah")
    end

    def do_get(podcast, query='')
      get :search, :podcast => podcast, :q => query
    end

    it "should be successful" do
      do_get(@podcast.clean_url)
      response.should be_success
    end

    it "should render index template" do
      do_get(@podcast.clean_url)
      response.should render_template('index')
    end

    it "should find all reviews" do
      Review.stub!(:search).and_return([@review, @review2])
      Review.should_receive(:search).and_return([@review, @review2])
      do_get(@podcast.clean_url)
    end

    it "should find all reviews with 'blah'" do
      Review.should_receive(:search).and_return([@review2])
      do_get(@podcast.clean_url, 'blah')
      assigns[:reviews].should == [@review2]
    end

  end

  describe "handling POST /:podcast/reviews/1" do
    def do_post(review)
      put :update, :podcast => @podcast.clean_url, :id => review.id, :review => { :title => 'newish' }
    end

    it "should update the review" do
      request.env["HTTP_REFERER"] = "http://www.google.com"
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

  describe 'rating a review' do
    before do
      @other_user = Factory.create(:user)
      login @other_user
    end

    def do_get(review, rating)
      request.env['HTTP_REFERER'] = ""
      get :rate, :podcast => @podcast.clean_url, :id => review.id, :rating => rating
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
  end
end
