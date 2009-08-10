require File.dirname(__FILE__) + '/../spec_helper'

describe SearchController do
  describe "route generation" do

    it "should map { :controller => 'search', :action => 'show' } to /search" do
      route_for(:controller => "search", :action => "show").should == "/search"
    end

  end

  describe "route recognition" do

    it "should generate params { :controller => 'search', action => 'show' } from GET /search?q=the" do
      params_from(:get, "/search").should == {:controller => "search", :action => "show"}
    end

  end

end
