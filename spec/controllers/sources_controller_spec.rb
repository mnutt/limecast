require File.dirname(__FILE__) + '/../spec_helper'

describe SourcesController do
  describe "handling GET /torrent_files/:id.torrent" do
    before(:each) do
      @feed    = Factory.create(:feed)
      @podcast = Factory.create(:podcast, :feeds => [@feed])
      @episode = Factory.create(:episode, :podcast => @podcast)
      @source  = Factory.create(:source, :feed => @feed, :episode => @episode, :torrent_file_name => "foobar.torrent")
    end

    def do_get
      get :show, :id => @source.to_param, :format => "torrent"
    end

    it "should show 404 for a source without torrent" do
      @source.update_attribute(:torrent, nil)
      do_get
      response.response_code.should be(404)
    end

    it "should redirect to the source's attachment url for the torrent" do
      do_get
      response.should redirect_to(@source.torrent.url)
    end
  end
end
