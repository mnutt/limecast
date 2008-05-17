require File.dirname(__FILE__) + '/../spec_helper'

describe EpisodesController do
  describe "route generation" do

    it "should map { :controller => 'episodes', :action => 'index' } to /episodes" do
      route_for(:controller => "episodes", :action => "index").should == "/episodes"
    end
  
    it "should map { :controller => 'episodes', :action => 'new' } to /episodes/new" do
      route_for(:controller => "episodes", :action => "new").should == "/episodes/new"
    end
  
    it "should map { :controller => 'episodes', :action => 'show', :id => 1 } to /episodes/1" do
      route_for(:controller => "episodes", :action => "show", :id => 1).should == "/episodes/1"
    end
  
    it "should map { :controller => 'episodes', :action => 'edit', :id => 1 } to /episodes/1/edit" do
      route_for(:controller => "episodes", :action => "edit", :id => 1).should == "/episodes/1/edit"
    end
  
    it "should map { :controller => 'episodes', :action => 'update', :id => 1} to /episodes/1" do
      route_for(:controller => "episodes", :action => "update", :id => 1).should == "/episodes/1"
    end
  
    it "should map { :controller => 'episodes', :action => 'destroy', :id => 1} to /episodes/1" do
      route_for(:controller => "episodes", :action => "destroy", :id => 1).should == "/episodes/1"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'episodes', action => 'index' } from GET /episodes" do
      params_from(:get, "/episodes").should == {:controller => "episodes", :action => "index"}
    end
  
    it "should generate params { :controller => 'episodes', action => 'new' } from GET /episodes/new" do
      params_from(:get, "/episodes/new").should == {:controller => "episodes", :action => "new"}
    end
  
    it "should generate params { :controller => 'episodes', action => 'create' } from POST /episodes" do
      params_from(:post, "/episodes").should == {:controller => "episodes", :action => "create"}
    end
  
    it "should generate params { :controller => 'episodes', action => 'show', id => '1' } from GET /episodes/1" do
      params_from(:get, "/episodes/1").should == {:controller => "episodes", :action => "show", :id => "1"}
    end
  
    it "should generate params { :controller => 'episodes', action => 'edit', id => '1' } from GET /episodes/1;edit" do
      params_from(:get, "/episodes/1/edit").should == {:controller => "episodes", :action => "edit", :id => "1"}
    end
  
    it "should generate params { :controller => 'episodes', action => 'update', id => '1' } from PUT /episodes/1" do
      params_from(:put, "/episodes/1").should == {:controller => "episodes", :action => "update", :id => "1"}
    end
  
    it "should generate params { :controller => 'episodes', action => 'destroy', id => '1' } from DELETE /episodes/1" do
      params_from(:delete, "/episodes/1").should == {:controller => "episodes", :action => "destroy", :id => "1"}
    end
  end
end