require File.dirname(__FILE__) + '/../spec_helper'

describe SearchController do
  describe "route generation" do

    it "should map { :controller => 'search', :action => 'index' } to /search" do
      route_for(:controller => "search", :action => "index").should == "/search"
    end

  end

  describe "route recognition" do

    it "should generate params { :controller => 'search', action => 'index' } from GET /search?q=the" do
      params_from(:get, "/search").should == {:controller => "search", :action => "index"}
    end

  end

end
