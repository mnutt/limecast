require File.dirname(__FILE__) + '/../spec_helper'

describe PodcastsController do
  describe "route generation" do

    it "should map { :controller => 'podcasts', :action => 'index' } to /podcasts" do
      route_for(:controller => "podcasts", :action => "index").should == "/podcasts"
    end
  
    it "should map { :controller => 'podcasts', :action => 'new' } to /podcasts/new" do
      route_for(:controller => "podcasts", :action => "new").should == "/podcasts/new"
    end
  
    it "should map { :controller => 'podcasts', :action => 'show', :id => 1 } to /podcasts/1" do
      route_for(:controller => "podcasts", :action => "show", :id => 1).should == "/podcasts/1"
    end
  
    it "should map { :controller => 'podcasts', :action => 'edit', :id => 1 } to /podcasts/1/edit" do
      route_for(:controller => "podcasts", :action => "edit", :id => 1).should == "/podcasts/1/edit"
    end
  
    it "should map { :controller => 'podcasts', :action => 'update', :id => 1} to /podcasts/1" do
      route_for(:controller => "podcasts", :action => "update", :id => 1).should == "/podcasts/1"
    end
  
    it "should map { :controller => 'podcasts', :action => 'destroy', :id => 1} to /podcasts/1" do
      route_for(:controller => "podcasts", :action => "destroy", :id => 1).should == "/podcasts/1"
    end

    it "should map { :controller => 'podcasts', :action => 'cover', :id => 1} to /podcasts/1/cover" do
      route_for(:controller => "podcasts", :action => "cover", :podcast => "mypodcast").should == "/mypodcast/cover"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'podcasts', action => 'index' } from GET /podcasts" do
      params_from(:get, "/podcasts").should == {:controller => "podcasts", :action => "index"}
    end
  
    it "should generate params { :controller => 'podcasts', action => 'new' } from GET /podcasts/new" do
      params_from(:get, "/podcasts/new").should == {:controller => "podcasts", :action => "new"}
    end
  
    it "should generate params { :controller => 'podcasts', action => 'create' } from POST /podcasts" do
      params_from(:post, "/podcasts").should == {:controller => "podcasts", :action => "create"}
    end
  
    it "should generate params { :controller => 'podcasts', action => 'show', id => '1' } from GET /podcasts/1" do
      params_from(:get, "/podcasts/1").should == {:controller => "podcasts", :action => "show", :id => "1"}
    end
  
    it "should generate params { :controller => 'podcasts', action => 'edit', id => '1' } from GET /podcasts/1;edit" do
      params_from(:get, "/podcasts/1/edit").should == {:controller => "podcasts", :action => "edit", :id => "1"}
    end
  
    it "should generate params { :controller => 'podcasts', action => 'update', id => '1' } from PUT /podcasts/1" do
      params_from(:put, "/podcasts/1").should == {:controller => "podcasts", :action => "update", :id => "1"}
    end
  
    it "should generate params { :controller => 'podcasts', action => 'destroy', id => '1' } from DELETE /podcasts/1" do
      params_from(:delete, "/podcasts/1").should == {:controller => "podcasts", :action => "destroy", :id => "1"}
    end

    it "should generate params { :controller => 'podcasts', action => 'cover', id => '1' } from GET /podcasts/1" do
      params_from(:get, "/mypodcast/cover").should == {:controller => "podcasts", :action => "cover", :podcast => "mypodcast"}
    end
  end
end
