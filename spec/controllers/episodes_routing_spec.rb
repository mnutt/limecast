require File.dirname(__FILE__) + '/../spec_helper'

describe EpisodesController do
  describe "route generation" do
    it "should map { :podcast_slug => 'Podcast', :controller => 'episodes', :action => 'index' } to /Podcast/episodes" do
      route_for(:podcast => "Podcast", :controller => "episodes", :action => "index").should == "/Podcast/episodes"
    end

    it "should map { :podcast_slug => 'Podcast', :controller => 'episodes', :action => 'search' } to /Podcast/episodes/search" do
      route_for(:podcast => "Podcast", :controller => "episodes", :action => "search").should == "/Podcast/episodes/search"
    end

    it "should map { :podcast_slug => 'Podcast', :controller => 'episodes', :action => 'show', :id => 2008-Aug-28 } to /Podcast/2008-Aug-28" do
      route_for(:podcast => "Podcast", :controller => "episodes", :action => "show", :episode => "2008-Aug-28").should == "/Podcast/2008-Aug-28"
    end
  end

  describe "route recognition" do
    it "should generate params { :podcast_slug => 'Podcast', :controller => 'episodes', :action => 'index' } from GET /Podcast/episodes" do
      params_from(:get, "/Podcast/episodes").should == {:podcast => 'Podcast', :controller => "episodes", :action => "index"}
    end

    it "should generate params { :podcast_slug => 'Podcast', :controller => 'episodes', :action => 'search' } from GET /Podcast/episodes/search" do
      params_from(:get, "/Podcast/episodes/search").should == {:podcast => 'Podcast', :controller => "episodes", :action => "search"}
    end

    it "should generate params { :podcast_slug => 'Podcast', :controller => 'episodes', :action => 'show', :episode => '2008-Aug-28' } from GET /Podcast/2008-Aug-28" do
      params_from(:get, "/Podcast/2008-Aug-28").should == {:podcast => 'Podcast', :controller => "episodes", :action => "show", :episode => "2008-Aug-28"}
    end
  end
end
