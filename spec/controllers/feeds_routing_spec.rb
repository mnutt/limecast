require File.dirname(__FILE__) + '/../spec_helper'

describe FeedsController do
  describe "route generation" do

    it "should map { :controller => 'feeds', :action => 'add' } to /add" do
      route_for(:controller => "feeds", :action => "new").should == "/add"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'feeds', action => 'new' } from GET /add" do
      params_from(:get, "/add").should == {:controller => "feeds", :action => "new"}
    end

    it "should generate params { :controller => 'feeds', action => 'show', :id => '785-Diggnation-256k-mp3.xml'} from GET /plain_feed/785-Diggnation-256k-mp3.xml" do
      params_from(:get, "/plain_feed/785-Diggnation-256k-mp3.xml").should == {:controller => "feeds", :action => "show", :type => :plain, :id => "785-Diggnation-256k-mp3"}
    end

    it "should generate params { :controller => 'feeds', action => 'show', :id => '785-Diggnation-256k-mp3-magnet.xml'} from GET /magnet_feed/785-Diggnation-256k-mp3-magnet.xml" do
      params_from(:get, "/magnet_feed/785-Diggnation-256k-mp3-magnet.xml").should == {:controller => "feeds", :action => "show", :type => :magnet, :id => "785-Diggnation-256k-mp3-magnet"}
    end

    it "should generate params { :controller => 'feeds', action => 'show', :id => '785-Diggnation-256k-mp3-torrent.xml'} from GET /torrent_feed/785-Diggnation-256k-mp3-torrent.xml" do
      params_from(:get, "/torrent_feed/785-Diggnation-256k-mp3-torrent.xml").should == {:controller => "feeds", :action => "show", :type => :torrent, :id => "785-Diggnation-256k-mp3-torrent"}
    end
  end
end
