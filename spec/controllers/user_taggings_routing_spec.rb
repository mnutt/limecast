require File.dirname(__FILE__) + '/../spec_helper'

describe UserTaggingsController do
  describe "route recognition" do
    it "should generate params { :controller => 'taggings', :action => 'destroy', :id => '1' } from DELETE /user_taggings/1" do
      params_from(:delete, "/user_taggings/1").should == {:controller => "user_taggings", :action => "destroy", :id => "1"}
    end
  end
end
