require File.dirname(__FILE__) + '/../spec_helper'

describe ReviewsController do
  describe "route generation" do
    it "should map { :podcast_slug => 'Podcast', :controller => 'reviews', :action => 'index' } to /Podcast/reviews" do
      route_for(:podcast => "Podcast", :controller => "reviews", :action => "index").should == "/Podcast/reviews"
    end

    it "should map { :podcast_slug => 'Podcast', :controller => 'reviews', :action => 'search' } to /Podcast/reviews/search" do
      route_for(:podcast => "Podcast", :controller => "reviews", :action => "search").should == "/Podcast/reviews/search"
    end

    it "should map { :podcast_slug => 'Podcast', :controller => 'reviews', :action => 'show', :id => '1' } to /Podcast/reviews/1" do
      route_for(:podcast => "Podcast", :controller => "reviews", :action => "show", :id => "1").should == "/Podcast/reviews/1"
    end
  end

  describe "route recognition" do
    it "should generate params { :podcast_slug => 'Podcast', :controller => 'reviews', :action => 'index' } from GET /Podcast/reviews" do
      params_from(:get, "/Podcast/reviews").should == {:podcast => 'Podcast', :controller => "reviews", :action => "index"}
    end

    it "should generate params { :podcast_slug => 'Podcast', :controller => 'reviews', :action => 'search' } from GET /Podcast/reviews/search" do
      params_from(:get, "/Podcast/reviews/search").should == {:podcast => 'Podcast', :controller => "reviews", :action => "search"}
    end

    it "should generate params { :podcast_slug => 'Podcast', :controller => 'reviews', :action => 'show', :id => '1' } from GET /Podcast/reviews/1" do
      params_from(:get, "/Podcast/reviews/1").should == {:podcast => 'Podcast', :controller => "reviews", :action => "show", :id => "1"}
    end
  end
end
