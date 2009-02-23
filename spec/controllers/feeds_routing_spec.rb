require File.dirname(__FILE__) + '/../spec_helper'

describe FeedsController do
  describe "route generation" do

    it "should map { :controller => 'feeds', :action => 'add' } to /add" do
      route_for(:controller => "feeds", :action => "new").should == "/add"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'feeds', action => 'new' } from GET /add" do
      params_from(:get, "/add").should == {:controller => "feeds", :action => "new"}
    end

  end
end
