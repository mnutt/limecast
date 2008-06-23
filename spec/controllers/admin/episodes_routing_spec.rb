require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::EpisodesController do
  describe "route generation" do

    it "should map { :controller => 'admin_episodes', :action => 'index' } to /admin_episodes" do
      route_for(:controller => "admin_episodes", :action => "index").should == "/admin_episodes"
    end
  
    it "should map { :controller => 'admin_episodes', :action => 'new' } to /admin_episodes/new" do
      route_for(:controller => "admin_episodes", :action => "new").should == "/admin_episodes/new"
    end
  
    it "should map { :controller => 'admin_episodes', :action => 'show', :id => 1 } to /admin_episodes/1" do
      route_for(:controller => "admin_episodes", :action => "show", :id => 1).should == "/admin_episodes/1"
    end
  
    it "should map { :controller => 'admin_episodes', :action => 'edit', :id => 1 } to /admin_episodes/1/edit" do
      route_for(:controller => "admin_episodes", :action => "edit", :id => 1).should == "/admin_episodes/1/edit"
    end
  
    it "should map { :controller => 'admin_episodes', :action => 'update', :id => 1} to /admin_episodes/1" do
      route_for(:controller => "admin_episodes", :action => "update", :id => 1).should == "/admin_episodes/1"
    end
  
    it "should map { :controller => 'admin_episodes', :action => 'destroy', :id => 1} to /admin_episodes/1" do
      route_for(:controller => "admin_episodes", :action => "destroy", :id => 1).should == "/admin_episodes/1"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'admin_episodes', action => 'index' } from GET /admin_episodes" do
      params_from(:get, "/admin_episodes").should == {:controller => "admin_episodes", :action => "index"}
    end
  
    it "should generate params { :controller => 'admin_episodes', action => 'new' } from GET /admin_episodes/new" do
      params_from(:get, "/admin_episodes/new").should == {:controller => "admin_episodes", :action => "new"}
    end
  
    it "should generate params { :controller => 'admin_episodes', action => 'create' } from POST /admin_episodes" do
      params_from(:post, "/admin_episodes").should == {:controller => "admin_episodes", :action => "create"}
    end
  
    it "should generate params { :controller => 'admin_episodes', action => 'show', id => '1' } from GET /admin_episodes/1" do
      params_from(:get, "/admin_episodes/1").should == {:controller => "admin_episodes", :action => "show", :id => "1"}
    end
  
    it "should generate params { :controller => 'admin_episodes', action => 'edit', id => '1' } from GET /admin_episodes/1;edit" do
      params_from(:get, "/admin_episodes/1/edit").should == {:controller => "admin_episodes", :action => "edit", :id => "1"}
    end
  
    it "should generate params { :controller => 'admin_episodes', action => 'update', id => '1' } from PUT /admin_episodes/1" do
      params_from(:put, "/admin_episodes/1").should == {:controller => "admin_episodes", :action => "update", :id => "1"}
    end
  
    it "should generate params { :controller => 'admin_episodes', action => 'destroy', id => '1' } from DELETE /admin_episodes/1" do
      params_from(:delete, "/admin_episodes/1").should == {:controller => "admin_episodes", :action => "destroy", :id => "1"}
    end
  end
end