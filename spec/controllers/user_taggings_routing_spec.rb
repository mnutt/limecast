require File.dirname(__FILE__) + '/../spec_helper'

describe UserTaggingsController do
  describe "route generation" do
    # none
  end

  describe "route recognition" do
    it "should generate params { :controller => 'user_taggings', :action => 'destroy', :id => '1' } from DELETE /user_taggings/1" do
      params_from(:delete, "/user_taggings/1").should == {:controller => "user_taggings", :action => "destroy", :id => "1"}
    end

    it "should generate params { :controller => 'user_taggings', :action => 'create' } from POST /user_taggings" do
      params_from(:post, "/user_taggings").should == {:controller => "user_taggings", :action => "create"}
    end
  end
end
