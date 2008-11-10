require File.dirname(__FILE__) + '/../spec_helper'

describe CommentsController do
  fixtures :users

  before(:each) do
    @user = Factory.create(:user)
    @podcast = Factory.create(:podcast)
    @episode = Factory.create(:episode, :podcast => @podcast)
    @review = Factory.create(:comment, :commenter => @user, :episode => @episode)
    login(@user)
  end

  describe "handling POST /:podcast/comments/1" do
    def do_post(review)
      put :update, :podcast => @podcast.clean_url, :id => review.id, :comment => { :title => 'newish' }
    end
    
    it "should redirect" do
      do_post(@review)
      response.should redirect_to(review_url(:podcast => @podcast, :id => @review.id))
    end
    
    it "should update the comment" do
      do_post(@review)
      @review.reload.title.should eql("newish")
    end
  end

  describe "handling DESTROY /:podcast/comments/1" do
    def do_destroy(review)
      delete :destroy, :podcast => @podcast.clean_url, :id => review.id
    end

    it "should be successful" do
      do_destroy(@review)
      response.should be_success
    end
    
    it "should delete the comment" do
      lambda { do_destroy(@review) }.should change { @podcast.comments.count }.by(-1)
    end
  end
end