require File.dirname(__FILE__) + '/../spec_helper'

module StopParse
  def parse(*args); end
end
describe EpisodesController do
  before(:each) do
    @episode = Factory.create(:episode, :published_at => Time.now)
    @podcast = @episode.podcast
    @feed = @podcast.feeds.first
    @feed.extend(StopParse)
    @source = Factory.create(:source, :episode => @episode, :feed => @feed)
  end

  describe "handling GET /:podcast/episodes" do
    def do_get(podcast)
      get :index, :podcast => podcast
    end

    it "should be successful" do
      do_get(@podcast.clean_url)
      response.should be_success
    end

    it "should render index template" do
      do_get(@podcast.clean_url)
      response.should render_template('index')
    end

    it "should find all episodes" do
      Episode.should_receive(:find).and_return([@episode])
      do_get(@podcast.clean_url)
    end

    it "should assign the found episodes for the view" do
      do_get(@podcast.clean_url)
      assigns[:episodes].should == [@episode]
    end
  end

  describe "handling GET /:podcast/:episode" do
    def do_get(podcast, episode)
      get :show, :podcast => podcast, :episode => episode
    end

    it "should be successful" do
      do_get(@podcast.clean_url, @episode.clean_url)
      response.should be_success
    end

    it "should render show template" do
      do_get(@podcast.clean_url, @episode.clean_url)
      response.should render_template('show')
    end

    it "should assign the found episode for the view" do
      do_get(@podcast.clean_url, @episode.clean_url)
      assigns[:episode].id.should equal(@episode.id)
    end
  end

#   describe "handling DELETE /:podcast/:episodes" do
#     def do_get(podcast, episode)
#       get :destroy, :podcast => podcast, :episode => episode
#     end
#
#     it "should find the episode requested" do
#       Episode.should_receive(:find).and_return(@episode)
#       do_get(@podcast.clean_url, @episode.clean_url)
#     end
#
#     it "should call destroy on the found episode" do
#       @episode.should_receive(:destroy)
#       do_get(@podcast.clean_url, @episode.clean_url)
#     end
#
#     it "should redirect to the episodes list" do
#       do_get(@podcast.clean_url, @episode.clean_url)
#       response.should redirect_to(episodes_url)
#     end
#   end

  describe "handling GET /:podcast/:episode" do
    def do_get(podcast, episode)
      get :show, :podcast => podcast, :episode => episode
    end

    it "should be successful" do
      do_get(@podcast.clean_url, @episode.clean_url)
      response.should be_success
    end

    it "should render show template" do
      do_get(@podcast.clean_url, @episode.clean_url)
      response.should render_template('show')
    end

    it "should assign episode" do
      do_get(@podcast.clean_url, @episode.clean_url)
      assigns[:episode].should == @episode
    end

  end
end
