require File.dirname(__FILE__) + '/../spec_helper'

describe TagsController do
  describe "route generation" do
    it "should map { :controller => 'tags', :action => 'index' } to /Podcast/tags" do
      route_for(:controller => "tags", :action => "index").should == "/tags"
    end

    it "should map { :controller => 'tags', :action => 'show',  :tag => 'video' } to /tags/video" do
      route_for(:controller => "tags", :action => "show", :tag => 'video').should == "/tag/video"
    end

    it "should map { :controller => 'tags', :action => 'search',  :tag => 'video' } to /tags/video/search" do
      route_for(:controller => "tags", :action => "search", :tag => 'video').should == "/tag/video/search"
    end
  end

  describe "route recognition" do
    it "should generate params { :controller => 'tags', :action => 'index' } from GET /tags/video" do
      params_from(:get, "/tags").should == {:controller => "tags", :action => "index"}
    end

    it "should generate params { :controller => 'tags', :action => 'show',  :tag => 'video' } from GET /tags/video" do
      params_from(:get, "/tag/video").should == {:controller => "tags", :action => "show",  :tag => 'video'}
    end

    it "should generate params { :controller => 'tags', :action => 'search',  :tag => 'video' } from GET /tags/video/search" do
      params_from(:get, "/tag/video/search").should == {:controller => "tags", :action => "search",  :tag => 'video'}
    end
  end
end
