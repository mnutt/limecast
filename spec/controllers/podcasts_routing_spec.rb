require File.dirname(__FILE__) + '/../spec_helper'

describe PodcastsController do
  describe "route generation" do

    it "should map { :controller => 'podcasts', :action => 'index' } to /all" do
      route_for(:controller => "podcasts", :action => "index").should == "/all"
    end

    it "should map { :controller => 'podcasts', :action => 'show', :podcast_slug => 'mypodcast' } to /mypodcast" do
      route_for(:controller => "podcasts", :action => "show", :podcast_slug => 'mypodcast').should == "/mypodcast"
    end

    it "should map { :controller => 'podcasts', :action => 'edit', :podcast_slug => 'mypodcast' } to /mypodcast/edit" do
      route_for(:controller => "podcasts", :action => "edit", :podcast_slug => 'mypodcast').should == "/mypodcast/edit"
    end

    it "should map { :controller => 'podcasts', :action => 'cover', :podcast_slug => 'mypodcast'} to /mypodcast/cover" do
      route_for(:controller => "podcasts", :action => "cover", :podcast_slug => "mypodcast").should == "/mypodcast/cover"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'podcasts', action => 'index' } from GET /all" do
      params_from(:get, "/all").should == {:controller => "podcasts", :action => "index"}
    end

    it "should generate params { :controller => 'podcasts', action => 'show', podcast_slug => 'mypodcast' } from GET /mypodcast" do
      params_from(:get, "/mypodcast").should == {:controller => "podcasts", :action => "show", :podcast_slug => 'mypodcast'}
    end

    it "should generate params { :controller => 'podcasts', action => 'edit', podcast_slug => 'mypodcast' } from GET /mypodcast/edit" do
      params_from(:get, "/mypodcast/edit").should == {:controller => "podcasts", :action => "edit", :podcast_slug => 'mypodcast'}
    end

    it "should generate params { :controller => 'podcasts', action => 'update', podcast_slug => 'mypodcast' } from PUT /mypodcast" do
      params_from(:put, "/mypodcast").should == {:controller => "podcasts", :action => "update", :podcast_slug => 'mypodcast'}
    end

    it "should generate params { :controller => 'podcasts', action => 'destroy', podcast_slug => 'mypodcast' } from DELETE /mypodcast" do
      params_from(:delete, "/mypodcast").should == {:controller => "podcasts", :action => "destroy", :podcast_slug => 'mypodcast'}
    end

    it "should generate params { :controller => 'podcasts', action => 'cover', podcast_slug => 'mypodcast' } from GET /mypodcast/cover" do
      params_from(:get, "/mypodcast/cover").should == {:controller => "podcasts", :action => "cover", :podcast_slug => "mypodcast"}
    end

    it "should generate params { :podcast_slug => 'mypodcast', :controller => 'episodes', :action => 'favorite' } from POST /mypodcast/favorite" do
      params_from(:post, "/mypodcast/favorite").should == {:podcast_slug => 'mypodcast', :controller => "podcasts", :action => "favorite"}
    end

    it "should generate params { :podcast_slug => 'mypodcast', :controller => 'podcasts', :action => 'tag' } from POST /mypodcast/tag" do
      params_from(:put, "/mypodcast/tag").should == {:podcast_slug => 'mypodcast', :controller => "podcasts", :action => "tag"}
    end
  end
end
