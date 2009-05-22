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

    it "should map { :controller => 'podcasts', :action => 'add' } to /add" do
      route_for(:controller => "podcasts", :action => "new").should == "/add"
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

    it "should generate params { :controller => 'podcasts', action => 'show', :id => '785-Diggnation-256k-mp3.xml'} from GET /plain_feeds/785-Diggnation-256k-mp3.xml" do
      params_from(:get, "/plain_feeds/785-Diggnation-256k-mp3.xml").should == {:controller => "podcasts", :action => "feed", :type => :plain, :id => "785-Diggnation-256k-mp3"}
    end

    it "should generate params { :controller => 'podcasts', action => 'show', :id => '785-Diggnation-256k-mp3-magnet.xml'} from GET /magnet_feeds/785-Diggnation-256k-mp3-magnet.xml" do
      params_from(:get, "/magnet_feeds/785-Diggnation-256k-mp3-magnet.xml").should == {:controller => "podcasts", :action => "feed", :type => :magnet, :id => "785-Diggnation-256k-mp3-magnet"}
    end

    it "should generate params { :controller => 'podcasts', action => 'show', :id => '785-Diggnation-256k-mp3-torrent.xml'} from GET /torrent_feeds/785-Diggnation-256k-mp3-torrent.xml" do
      params_from(:get, "/torrent_feeds/785-Diggnation-256k-mp3-torrent.xml").should == {:controller => "podcasts", :action => "feed", :type => :torrent, :id => "785-Diggnation-256k-mp3-torrent"}
    end
    
    it "should generate params { :controller => 'podcasts', action => 'new' } from GET /add" do
      params_from(:get, "/add").should == {:controller => "podcasts", :action => "new"}
    end
    
    it "should generate params { :controller => 'podcasts', action => 'create' } from GET /podcasts" do
      params_from(:post, "/podcasts").should == {:controller => "podcasts", :action => "create"}
    end
  end
end
