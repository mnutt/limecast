require File.dirname(__FILE__) + '/../spec_helper'

module StopRemoveEmptyPodcast
  def remove_empty_podcast(*args); end
end
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
      @podcast.feeds.first.extend(StopRemoveEmptyPodcast)
      @podcast.feeds.first.refresh
      @podcast.reload
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

  describe "handling GET /:podcast/cover" do
    before(:each) do
      @podcast = Factory.create(:parsed_podcast)
      get :cover, :podcast => @podcast.clean_url
    end

    it 'should assign the podcast' do
      assigns(:podcast).should == @podcast
    end

    it 'should render the cover template' do
      response.should render_template('podcasts/cover')
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

    it "should not save the new podcast" do
      @podcast.should_not_receive(:save)
      do_get
    end
  end

  describe "handling POST /podcasts when not logged in" do
    before(:each) do
      post :create, :feed => {:url => "http://mypodcast/feed.xml"}
    end

    it 'should save a feed' do
      assigns(:feed).should be_kind_of(Feed)
      assigns(:feed).should_not be_new_record
    end

    it 'should add the feed to the session' do
      session.data[:feeds].should include(assigns(:feed).id)
    end

    it 'should not associate the feed with a user' do
      assigns(:feed).finder.should be_nil
    end
  end

  describe "handling POST /podcasts when logged in" do
    before(:each) do
      @user = Factory.create(:user)
      login(@user)
      post :create, :feed => {:url => "http://mypodcast/feed.xml"}
    end

    it 'should save the podcast' do
      assigns(:feed).should be_kind_of(Feed)
      assigns(:feed).should_not be_new_record
    end

    it 'should associate the podcast with the user' do
      assigns(:feed).finder.should == @user
    end

    it 'should create a feed' do
      assigns(:feed).should be_kind_of(Feed)
      assigns(:feed).url.should == "http://mypodcast/feed.xml"
    end
  end

  describe "handling DELETE /podcasts/1" do
    describe "when user is the podcast owner" do

      before(:each) do
        @user = mock_model(User)
        @podcast = mock_model(Podcast, :destroy => true)
        Podcast.stub!(:find).and_return(@podcast)
        @podcast.should_receive(:writable_by?).and_return(true)
        login(@user)
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

    describe "when user is not authorized" do

      before(:each) do
        @user = mock_model(User)
        @podcast = mock_model(Podcast, :destroy => true)
        Podcast.stub!(:find).and_return(@podcast)
        @podcast.should_receive(:writable_by?).and_return(false)
        login(@user)
      end

      it "should redirect to the podcasts list" do
        lambda {
          delete :destroy, :id => "1"
        }.should raise_error(Forbidden)
      end
    end
  end

  describe "handling POST /:podcast" do
    describe "when user is the podcast owner" do

      before(:each) do
        @user = Factory.create(:user)
        @podcast = Factory.create(:parsed_podcast)
        Podcast.stub!(:find_by_clean_url).and_return(@podcast)
        @podcast.should_receive(:writable_by?).and_return(true)
        login(@user)

        post :update, :podcast => @podcast.clean_url, :podcast_attr => {:custom_title => "Custom Title"}
      end

      it "should find the podcast requested" do
        assigns(:podcast).id.should == @podcast.id
      end

      it "should update the found podcast" do
        assigns(:podcast).reload.custom_title.should == "Custom Title"
      end

      it "should redirect to the podcasts list" do
        response.should redirect_to(podcast_url(:podcast => @podcast))
      end
    end

    describe "when user is not authorized" do

      before(:each) do
        @user = Factory.create(:user)
        @podcast = Factory.create(:parsed_podcast)
        Podcast.stub!(:find_by_clean_url).and_return(@podcast)
        @podcast.should_receive(:writable_by?).and_return(false)
        login(@user)
      end

      it "should redirect to the podcasts list" do
        lambda {
          post :update, :podcast => @podcast.clean_url, :podcast_attr => {:custom_title => "Custom Title"}
        }.should raise_error(Forbidden)
      end
    end

    describe "when user enters malicious params" do

      before(:each) do
        @user = Factory.create(:user)
        @podcast = Factory.create(:podcast, :feeds => [Factory.create(:feed, :finder => @user)], :owner_email => "test@example.com")
        login(@user)

        post :update, :podcast => @podcast.clean_url, :podcast_attr => {:owner_email => "malicious@example.com"}
      end

      it "should not change the params" do
        assigns(:podcast).owner_email.should == "test@example.com"
      end
    end
  end

  
  describe "handling POST /:podcast/favorite" do
    before do
      @user = Factory.create(:user)
      @podcast = Factory.create(:podcast)
      login @user
    end
    
    def do_post(podcast)
      xhr :post, :favorite, :podcast => podcast.clean_url
    end
    
    it "should be successful" do
      do_post(@podcast).should be_success
    end
    
    it "should increment the favorite count by 1" do
      lambda { do_post(@podcast) }.should change { @podcast.favorites.count }.by(1)
    end
    
    it "should act as a toggle for an episodes favorites" do
      lambda { do_post(@podcast) }.should change { @podcast.favorites.count }.by(1)
      lambda { do_post(@podcast) }.should change { @podcast.favorites.count }.by(-1)
      lambda { do_post(@podcast) }.should change { @podcast.favorites.count }.by(1)
      lambda { do_post(@podcast) }.should change { @podcast.favorites.count }.by(-1)
    end
  end
  
end
