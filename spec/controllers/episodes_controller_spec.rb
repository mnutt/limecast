require File.dirname(__FILE__) + '/../spec_helper'

module StopParse
  def parse(*args); end
end
describe EpisodesController do
  before(:each) do
    @episode = Factory.create(:episode, :published_at => Time.now, :sources => [])
    @podcast = @episode.podcast
    @podcast.extend(StopParse)
    @source = Factory.create(:source, :episode => @episode, :podcast => @podcast)
  end

  describe "handling GET /:podcast_slug/episodes" do
    def do_get(podcast)
      get :index, :podcast_slug => podcast
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

  describe "handling GET /:podcast_slug/episodes/search" do
    before(:each) do
      @episode2 = Factory.create(:episode, :published_at => 2.days.ago, :summary => "blah blah")
      @source = Factory.create(:source, :episode => @episode2, :podcast => @podcast)
    end

    def do_get(podcast, query='')
      get :search, :podcast_slug => podcast, :q => query
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
      Episode.stub!(:search).and_return([@episodes, @episode2])
      Episode.should_receive(:search).and_return([@episode, @episode2])
      do_get(@podcast.clean_url)
    end

    it "should find all episodes with 'blah'" do
      Episode.should_receive(:search).and_return([@episode2])
      do_get(@podcast.clean_url, 'blah')
      assigns[:episodes].should == [@episode2]
    end

  end

  describe "handling GET /:podcast_slug/:episode" do
    def do_get(podcast, episode)
      get :show, :podcast_slug => podcast, :episode => episode
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

#   describe "handling DELETE /:podcast_slug/:episodes" do
#     def do_get(podcast, episode)
#       get :destroy, :podcast_slug => podcast, :episode => episode
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

  describe "handling GET /:podcast_slug/:episode" do
    def do_get(podcast, episode)
      get :show, :podcast_slug => podcast, :episode => episode
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
