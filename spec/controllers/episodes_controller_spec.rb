require File.dirname(__FILE__) + '/../spec_helper'

describe EpisodesController do
  before(:each) do
    @episode = Factory.create(:episode)
    @podcast = @episode.podcast
  end

  describe "handling GET /:podcast/episodes" do
    def do_get(podcast)
      get :index, :podcast => podcast
    end
  
    it "should be successful" do
      do_get(@podcast.clean_title)
      response.should be_success
    end

    it "should render index template" do
      do_get(@podcast.clean_title)
      response.should render_template('index')
    end
  
    it "should find all episodes" do
      Episode.should_receive(:find).and_return([@episode])
      do_get(@podcast.clean_title)
    end
  
    it "should assign the found episodes for the view" do
      do_get(@podcast.clean_title)
      assigns[:episodes].should == [@episode]
    end
  end

  describe "handling GET /:podcast/:episode" do
    def do_get(podcast, episode)
      get :show, :podcast => podcast, :episode => episode
    end

    it "should be successful" do
      do_get(@podcast.clean_title, @episode.clean_title)
      response.should be_success
    end
  
    it "should render show template" do
      do_get(@podcast.clean_title, @episode.clean_title)
      response.should render_template('show')
    end
  
    it "should assign the found episode for the view" do
      do_get(@podcast.clean_title, @episode.clean_title)
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
#       do_get(@podcast.clean_title, @episode.clean_title)
#     end
#   
#     it "should call destroy on the found episode" do
#       @episode.should_receive(:destroy)
#       do_get(@podcast.clean_title, @episode.clean_title)
#     end
#   
#     it "should redirect to the episodes list" do
#       do_get(@podcast.clean_title, @episode.clean_title)
#       response.should redirect_to(episodes_url)
#     end
#   end
end
