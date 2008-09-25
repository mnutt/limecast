require File.dirname(__FILE__) + '/../spec_helper'

describe PodcastsController do
  describe "handling GET /" do
    before(:each) do
      @podcast = Factory.create(:parsed_podcast)
    end
  
    def do_get
      get :index
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should render index template" do
      do_get
      response.should render_template('index')
    end
  
    it "should assign the found podcasts for the view" do
      do_get
      assigns[:podcasts].should == [@podcast]
    end
  end

  describe "handling GET /:podcast" do
    before(:each) do
      @podcast = Factory.create(:parsed_podcast)
    end
  
    def do_get
      get :show, :podcast => @podcast.clean_url
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render show template" do
      do_get
      response.should render_template('show')
    end
  
    it "should assign the found podcast for the view" do
      do_get
      assigns[:podcast].id.should equal(@podcast.id)
    end
  end

  describe "handling GET /add" do

    before(:each) do
      @podcast = Podcast.new
    end
  
    def do_get
      get :new
    end

    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should render new template" do
      do_get
      response.should render_template('new')
    end

    it "should assign the new podcast for the view" do
      do_get
      assigns[:podcast].should be_a(Podcast)
    end
  
    it "should not save the new podcast" do
      @podcast.should_not_receive(:save)
      do_get
    end
  end

  describe "handling POST /podcasts when not logged in" do
    def do_post
      post :create, :podcast => {:feed_url => "http://mypodcast/feed.xml"}
    end

    it 'should save the podcast' do
      do_post
      assigns(:podcast).should be_kind_of(Podcast)
      assigns(:podcast).should_not be_new_record
    end

    it 'should add the podcast to the session' do
      do_post
      podcast = assigns(:podcast)
      session.data[:podcasts].should include(podcast.id)
    end
  end

# 
#   describe "handling GET /podcasts/1/edit" do
# 
#     before(:each) do
#       @podcast = mock_model(Podcast)
#       Podcast.stub!(:find).and_return(@podcast)
#     end
#   
#     def do_get
#       get :edit, :id => "1"
#     end
# 
#     it "should be successful" do
#       do_get
#       response.should be_success
#     end
#   
#     it "should render edit template" do
#       do_get
#       response.should render_template('edit')
#     end
#   
#     it "should find the podcast requested" do
#       Podcast.should_receive(:find).and_return(@podcast)
#       do_get
#     end
#   
#     it "should assign the found Podcast for the view" do
#       do_get
#       assigns[:podcast].should equal(@podcast)
#     end
#   end
#     
#     describe "with failed save" do
# 
#       def do_post
#         @podcast.should_receive(:save).and_return(false)
#         post :create, :podcast => {}
#       end
#   
#       it "should re-render 'new'" do
#         do_post
#         response.should render_template('new')
#       end
#       
#     end
#   end
# 
#   describe "handling DELETE /podcasts/1" do
# 
#     before(:each) do
#       @podcast = mock_model(Podcast, :destroy => true)
#       Podcast.stub!(:find).and_return(@podcast)
#     end
#   
#     def do_delete
#       delete :destroy, :id => "1"
#     end
# 
#     it "should find the podcast requested" do
#       Podcast.should_receive(:find).with("1").and_return(@podcast)
#       do_delete
#     end
#   
#     it "should call destroy on the found podcast" do
#       @podcast.should_receive(:destroy)
#       do_delete
#     end
#   
#     it "should redirect to the podcasts list" do
#       do_delete
#       response.should redirect_to(podcasts_url)
#     end
#   end
end
