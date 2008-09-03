# require File.dirname(__FILE__) + '/../../spec_helper'
# 
# describe Admin::UsersController do
#   describe "route generation" do
# 
#     it "should map { :controller => 'admin_users', :action => 'index' } to /admin_users" do
#       route_for(:controller => "admin_users", :action => "index").should == "/admin_users"
#     end
#   
#     it "should map { :controller => 'admin_users', :action => 'new' } to /admin_users/new" do
#       route_for(:controller => "admin_users", :action => "new").should == "/admin_users/new"
#     end
#   
#     it "should map { :controller => 'admin_users', :action => 'show', :id => 1 } to /admin_users/1" do
#       route_for(:controller => "admin_users", :action => "show", :id => 1).should == "/admin_users/1"
#     end
#   
#     it "should map { :controller => 'admin_users', :action => 'edit', :id => 1 } to /admin_users/1/edit" do
#       route_for(:controller => "admin_users", :action => "edit", :id => 1).should == "/admin_users/1/edit"
#     end
#   
#     it "should map { :controller => 'admin_users', :action => 'update', :id => 1} to /admin_users/1" do
#       route_for(:controller => "admin_users", :action => "update", :id => 1).should == "/admin_users/1"
#     end
#   
#     it "should map { :controller => 'admin_users', :action => 'destroy', :id => 1} to /admin_users/1" do
#       route_for(:controller => "admin_users", :action => "destroy", :id => 1).should == "/admin_users/1"
#     end
#   end
# 
#   describe "route recognition" do
# 
#     it "should generate params { :controller => 'admin_users', action => 'index' } from GET /admin_users" do
#       params_from(:get, "/admin_users").should == {:controller => "admin_users", :action => "index"}
#     end
#   
#     it "should generate params { :controller => 'admin_users', action => 'new' } from GET /admin_users/new" do
#       params_from(:get, "/admin_users/new").should == {:controller => "admin_users", :action => "new"}
#     end
#   
#     it "should generate params { :controller => 'admin_users', action => 'create' } from POST /admin_users" do
#       params_from(:post, "/admin_users").should == {:controller => "admin_users", :action => "create"}
#     end
#   
#     it "should generate params { :controller => 'admin_users', action => 'show', id => '1' } from GET /admin_users/1" do
#       params_from(:get, "/admin_users/1").should == {:controller => "admin_users", :action => "show", :id => "1"}
#     end
#   
#     it "should generate params { :controller => 'admin_users', action => 'edit', id => '1' } from GET /admin_users/1;edit" do
#       params_from(:get, "/admin_users/1/edit").should == {:controller => "admin_users", :action => "edit", :id => "1"}
#     end
#   
#     it "should generate params { :controller => 'admin_users', action => 'update', id => '1' } from PUT /admin_users/1" do
#       params_from(:put, "/admin_users/1").should == {:controller => "admin_users", :action => "update", :id => "1"}
#     end
#   
#     it "should generate params { :controller => 'admin_users', action => 'destroy', id => '1' } from DELETE /admin_users/1" do
#       params_from(:delete, "/admin_users/1").should == {:controller => "admin_users", :action => "destroy", :id => "1"}
#     end
#   end
# end