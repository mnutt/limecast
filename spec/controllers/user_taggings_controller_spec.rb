require File.dirname(__FILE__) + '/../spec_helper'

describe UserTaggingsController do
  describe "handling POST /user_taggings" do
    before do
      @user = Factory.create(:user)
      @podcast = Factory.create(:podcast)
    end
    
    def do_post(tag_string="gutentag", podcast_id=@podcast.id)
      post :create, :user_tagging => {:tag_string => tag_string, :podcast_id => podcast_id}
    end
    
    describe "not logged in" do
      it "should redirect to home" do
        do_post.should redirect_to('/')
      end
      
      it "should not change the taggings count" do
        lambda { do_post("five six seven eight") }.should change { Tagging.count + UserTagging.count }.by(0)
      end
    end

    describe "logged in" do
      before do
        login @user
      end

      it "should be redirected to podcast" do
        do_post.should redirect_to(podcast_url(@podcast))
      end
    
      it "should increment the taggings count by 1" do
        lambda { do_post }.should change { @podcast.taggings.count }.by(1)
      end
    
      it "should increment the taggings count by 4" do
        lambda { do_post("one two three four") }.should change { @podcast.taggings.count }.by(4)
      end

      it "should strip spaces if commas are used" do
        lambda { do_post("blaster master, zelda") }.should change { @podcast.taggings.count }.by(3)
        @podcast.tags.map(&:name).should include("blaster")
        @podcast.tags.map(&:name).should include("master")
        @podcast.tags.map(&:name).should include("zelda")
      end
      
      it "should redirect and not change the tagging if podcast not found" do
        lambda { do_post("gutentag", "not-a-podcast-id") }.should_not change { UserTagging.count }
        response.response_code.should be(404)
      end
      
      it "should set a flash message if regular user tries to add more than 8 tags" do
        lambda { do_post("tag1 tag2 tag3 tag4 tag5 tag6 tag7 tag8 tag9") }.should change { UserTagging.count }.by(8)
        response.should redirect_to(podcast_url(@podcast))
        flash[:notice].should == "You are only allowed to add 8 tags for this podcast."
      end
      
    end
  end

  describe "handling DELETE /user_tagging/:id" do
    before(:each) do
      @tagger = Factory.create(:user)
      @tag = Factory.create(:tag, :name => 'video')
      @podcast = Factory.create(:podcast)
      @podcast.feeds.first.update_attribute(:finder_id, Factory.create(:user).id) # setup the finder
      @tagging = Factory.create(:tagging, :tag => @tag, :podcast => @podcast)
      @user_tagging = Factory.create(:user_tagging, :tagging => @tagging, :user => @tagger)
    end

    def do_delete(options={})
      xhr :delete, :destroy, {:id => @user_tagging.id, :format => 'js'}.merge(options)
    end

    describe "not logged in" do
      it "should not work!" do
        lambda { do_delete }.should change { UserTagging.count }.by(0)
        response.response_code.should be(401)
      end
    end

    it "should succeed" do
      login(@tagger)
      do_delete
      response.should be_success
    end

    it "should NOT delete the UserTagging if not found" do
      login(@tagger)
      lambda { do_delete(:id => 'gutentag') }.should_not change { UserTagging.count }
      response.response_code.should be(404)
    end

    it "should NOT delete the UserTagging logged in as random user" do
      login(Factory.create(:user))
      lambda { do_delete }.should_not change { UserTagging.count }
      response.response_code.should be(403)
    end

    it "should delete the UserTagging as tagger" do
      login(@tagger)
      lambda { do_delete }.should change { UserTagging.count }.by(-1)
    end

    it "should delete the UserTagging as finder" do
      login(@podcast.finders.first)
      lambda { do_delete }.should change { UserTagging.count }.by(-1)
    end

    it "should delete the UserTagging as owner" do
      owner = Factory.create(:user)
      @podcast.update_attributes :owner_email => owner.email, :owner_id => owner.id
      login(owner)
      lambda { do_delete }.should change { UserTagging.count }.by(-1)
    end

    it "should delete the UserTagging as admin" do
      login(Factory.create(:admin_user))
      lambda { do_delete }.should change { UserTagging.count }.by(-1)
    end
  end
end
