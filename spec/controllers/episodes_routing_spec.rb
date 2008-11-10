require File.dirname(__FILE__) + '/../spec_helper'

describe EpisodesController do
  describe "route generation" do
    it "should map { :podcast => 'Podcast', :controller => 'episodes', :action => 'index' } to /Podcast/episodes" do
      route_for(:podcast => "Podcast", :controller => "episodes", :action => "index").should == "/Podcast/episodes"
    end
  
    it "should map { :podcast => 'Podcast', :controller => 'episodes', :action => 'show', :id => 2008-Aug-28 } to /Podcast/2008-Aug-28" do
      route_for(:podcast => "Podcast", :controller => "episodes", :action => "show", :episode => "2008-Aug-28").should == "/Podcast/2008-Aug-28"
    end
  end

  describe "route recognition" do
    it "should generate params { :podcast => 'Podcast', :controller => 'episodes', :action => 'index' } from GET /Podcast/episodes" do
      params_from(:get, "/Podcast/episodes").should == {:podcast => 'Podcast', :controller => "episodes", :action => "index"}
    end
  
    it "should generate params { :podcast => 'Podcast', :controller => 'episodes', :action => 'show', :episode => '2008-Aug-28' } from GET /Podcast/2008-Aug-28" do
      params_from(:get, "/Podcast/2008-Aug-28").should == {:podcast => 'Podcast', :controller => "episodes", :action => "show", :episode => "2008-Aug-28"}
    end

    it "should generate params { :podcast => 'Podcast', :controller => 'episodes', :action => 'favorite', :episode => '2008-Aug-28' } from POST /Podcast/2008-Aug-28/favorite" do
      params_from(:post, "/Podcast/2008-Aug-28/favorite").should == {:podcast => 'Podcast', :controller => "episodes", :action => "favorite", :episode => "2008-Aug-28"}
    end
  end
end