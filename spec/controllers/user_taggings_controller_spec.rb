require File.dirname(__FILE__) + '/../spec_helper'

describe UserTaggingsController do
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
