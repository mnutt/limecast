require File.dirname(__FILE__) + '/../spec_helper'

describe PodcastsController do
  describe "handling GET /podcasts" do

    before(:each) do
      @podcast = mock_model(Podcast)
      Podcast.stub!(:find).and_return([@podcast])
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
  
    it "should find all podcasts" do
      Podcast.should_receive(:find).with(:all).and_return([@podcast])
      do_get
    end
  
    it "should assign the found podcasts for the view" do
      do_get
      assigns[:podcasts].should == [@podcast]
    end
  end

  describe "handling GET /podcasts.xml" do

    before(:each) do
      @podcasts = mock("Array of Podcasts", :to_xml => "XML")
      Podcast.stub!(:find).and_return(@podcasts)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :index
    end
  
    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should find all podcasts" do
      Podcast.should_receive(:find).with(:all).and_return(@podcasts)
      do_get
    end
  
    it "should render the found podcasts as xml" do
      @podcasts.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /podcasts/1" do

    before(:each) do
      @podcast = mock_model(Podcast)
      Podcast.stub!(:find).and_return(@podcast)
    end
  
    def do_get
      get :show, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render show template" do
      do_get
      response.should render_template('show')
    end
  
    it "should find the podcast requested" do
      Podcast.should_receive(:find).with("1").and_return(@podcast)
      do_get
    end
  
    it "should assign the found podcast for the view" do
      do_get
      assigns[:podcast].should equal(@podcast)
    end
  end

  describe "handling GET /podcasts/1.xml" do

    before(:each) do
      @podcast = mock_model(Podcast, :to_xml => "XML")
      Podcast.stub!(:find).and_return(@podcast)
    end
  
    def do_get
      @request.env["HTTP_ACCEPT"] = "application/xml"
      get :show, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should find the podcast requested" do
      Podcast.should_receive(:find).with("1").and_return(@podcast)
      do_get
    end
  
    it "should render the found podcast as xml" do
      @podcast.should_receive(:to_xml).and_return("XML")
      do_get
      response.body.should == "XML"
    end
  end

  describe "handling GET /podcasts/new" do

    before(:each) do
      @podcast = mock_model(Podcast)
      Podcast.stub!(:new).and_return(@podcast)
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
  
    it "should create an new podcast" do
      Podcast.should_receive(:new).and_return(@podcast)
      do_get
    end
  
    it "should not save the new podcast" do
      @podcast.should_not_receive(:save)
      do_get
    end
  
    it "should assign the new podcast for the view" do
      do_get
      assigns[:podcast].should equal(@podcast)
    end
  end

  describe "handling GET /podcasts/1/edit" do

    before(:each) do
      @podcast = mock_model(Podcast)
      Podcast.stub!(:find).and_return(@podcast)
    end
  
    def do_get
      get :edit, :id => "1"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end
  
    it "should render edit template" do
      do_get
      response.should render_template('edit')
    end
  
    it "should find the podcast requested" do
      Podcast.should_receive(:find).and_return(@podcast)
      do_get
    end
  
    it "should assign the found Podcast for the view" do
      do_get
      assigns[:podcast].should equal(@podcast)
    end
  end

  describe "handling POST /podcasts" do

    before(:each) do
      @podcast = mock_model(Podcast, :to_param => "1")
      Podcast.stub!(:new).and_return(@podcast)
    end
    
    describe "with successful save" do
  
      def do_post
        @podcast.should_receive(:save).and_return(true)
        post :create, :podcast => {}
      end
  
      it "should create a new podcast" do
        Podcast.should_receive(:new).with({}).and_return(@podcast)
        do_post
      end

      it "should redirect to the new podcast" do
        do_post
        response.should redirect_to(podcast_url("1"))
      end
      
    end
    
    describe "with failed save" do

      def do_post
        @podcast.should_receive(:save).and_return(false)
        post :create, :podcast => {}
      end
  
      it "should re-render 'new'" do
        do_post
        response.should render_template('new')
      end
      
    end
  end

  describe "handling PUT /podcasts/1" do

    before(:each) do
      @podcast = mock_model(Podcast, :to_param => "1")
      Podcast.stub!(:find).and_return(@podcast)
    end
    
    describe "with successful update" do

      def do_put
        @podcast.should_receive(:update_attributes).and_return(true)
        put :update, :id => "1"
      end

      it "should find the podcast requested" do
        Podcast.should_receive(:find).with("1").and_return(@podcast)
        do_put
      end

      it "should update the found podcast" do
        do_put
        assigns(:podcast).should equal(@podcast)
      end

      it "should assign the found podcast for the view" do
        do_put
        assigns(:podcast).should equal(@podcast)
      end

      it "should redirect to the podcast" do
        do_put
        response.should redirect_to(podcast_url("1"))
      end

    end
    
    describe "with failed update" do

      def do_put
        @podcast.should_receive(:update_attributes).and_return(false)
        put :update, :id => "1"
      end

      it "should re-render 'edit'" do
        do_put
        response.should render_template('edit')
      end

    end
  end

  describe "handling DELETE /podcasts/1" do

    before(:each) do
      @podcast = mock_model(Podcast, :destroy => true)
      Podcast.stub!(:find).and_return(@podcast)
    end
  
    def do_delete
      delete :destroy, :id => "1"
    end

    it "should find the podcast requested" do
      Podcast.should_receive(:find).with("1").and_return(@podcast)
      do_delete
    end
  
    it "should call destroy on the found podcast" do
      @podcast.should_receive(:destroy)
      do_delete
    end
  
    it "should redirect to the podcasts list" do
      do_delete
      response.should redirect_to(podcasts_url)
    end
  end
end