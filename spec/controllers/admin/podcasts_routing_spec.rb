# require File.dirname(__FILE__) + '/../../spec_helper'
#
# describe Admin::PodcastsController do
#   describe "route generation" do
#
#     it "should map { :controller => 'admin_podcasts', :action => 'index' } to /admin_podcasts" do
#       route_for(:controller => "admin_podcasts", :action => "index").should == "/admin_podcasts"
#     end
#
#     it "should map { :controller => 'admin_podcasts', :action => 'new' } to /admin_podcasts/new" do
#       route_for(:controller => "admin_podcasts", :action => "new").should == "/admin_podcasts/new"
#     end
#
#     it "should map { :controller => 'admin_podcasts', :action => 'show', :id => 1 } to /admin_podcasts/1" do
#       route_for(:controller => "admin_podcasts", :action => "show", :id => 1).should == "/admin_podcasts/1"
#     end
#
#     it "should map { :controller => 'admin_podcasts', :action => 'edit', :id => 1 } to /admin_podcasts/1/edit" do
#       route_for(:controller => "admin_podcasts", :action => "edit", :id => 1).should == "/admin_podcasts/1/edit"
#     end
#
#     it "should map { :controller => 'admin_podcasts', :action => 'update', :id => 1} to /admin_podcasts/1" do
#       route_for(:controller => "admin_podcasts", :action => "update", :id => 1).should == "/admin_podcasts/1"
#     end
#
#     it "should map { :controller => 'admin_podcasts', :action => 'destroy', :id => 1} to /admin_podcasts/1" do
#       route_for(:controller => "admin_podcasts", :action => "destroy", :id => 1).should == "/admin_podcasts/1"
#     end
#   end
#
#   describe "route recognition" do
#
#     it "should generate params { :controller => 'admin_podcasts', action => 'index' } from GET /admin_podcasts" do
#       params_from(:get, "/admin_podcasts").should == {:controller => "admin_podcasts", :action => "index"}
#     end
#
#     it "should generate params { :controller => 'admin_podcasts', action => 'new' } from GET /admin_podcasts/new" do
#       params_from(:get, "/admin_podcasts/new").should == {:controller => "admin_podcasts", :action => "new"}
#     end
#
#     it "should generate params { :controller => 'admin_podcasts', action => 'create' } from POST /admin_podcasts" do
#       params_from(:post, "/admin_podcasts").should == {:controller => "admin_podcasts", :action => "create"}
#     end
#
#     it "should generate params { :controller => 'admin_podcasts', action => 'show', id => '1' } from GET /admin_podcasts/1" do
#       params_from(:get, "/admin_podcasts/1").should == {:controller => "admin_podcasts", :action => "show", :id => "1"}
#     end
#
#     it "should generate params { :controller => 'admin_podcasts', action => 'edit', id => '1' } from GET /admin_podcasts/1;edit" do
#       params_from(:get, "/admin_podcasts/1/edit").should == {:controller => "admin_podcasts", :action => "edit", :id => "1"}
#     end
#
#     it "should generate params { :controller => 'admin_podcasts', action => 'update', id => '1' } from PUT /admin_podcasts/1" do
#       params_from(:put, "/admin_podcasts/1").should == {:controller => "admin_podcasts", :action => "update", :id => "1"}
#     end
#
#     it "should generate params { :controller => 'admin_podcasts', action => 'destroy', id => '1' } from DELETE /admin_podcasts/1" do
#       params_from(:delete, "/admin_podcasts/1").should == {:controller => "admin_podcasts", :action => "destroy", :id => "1"}
#     end
#   end
# end
