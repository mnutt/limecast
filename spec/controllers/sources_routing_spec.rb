require File.dirname(__FILE__) + '/../spec_helper'

describe SourcesController do
  describe "route generation" do
    # 
  end

  describe "route recognition" do
    it "should generate params { :controller => 'sources', action => 'show', :id => '2568-Diggnation-2008-Nov-14-12mb-mp3.torrent', :format => 'torrent'} from GET /torrent_file/2568-Diggnation-2008-Nov-14-12mb-mp3.torrent" do
      params_from(:get, "/torrent_file/2568-Diggnation-2008-Nov-14-12mb-mp3.torrent").should == {:controller => "sources", :action => "show", :format => "torrent", :id => "2568-Diggnation-2008-Nov-14-12mb-mp3"}
    end
  end
end
