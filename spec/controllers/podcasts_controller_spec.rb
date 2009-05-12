require File.dirname(__FILE__) + '/../spec_helper'

describe PodcastsController do

  describe "handling GET /all.xml" do
    before(:each) do
      qf = Factory.create(:queued_feed)
      mod_and_run_podcast_processor(qf)
      @podcast = qf.podcast
    end

    def do_get
      get :index, :format => "xml"
    end

    it "should be successful" do
      do_get
      response.should be_success
    end

    it 'should return xml as content_type' do
      do_get
      response.content_type.should eql('application/xml')
    end

    it "should render index template" do
      do_get
      response.should render_template('index.xml.builder')
    end
  end

  describe "handling GET /" do
    before(:each) do
      qf = Factory.create(:queued_feed)
      mod_and_run_podcast_processor(qf)
      @podcast = qf.podcast
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

  describe "handling GET /:podcast_slug" do
    before(:each) do
      qf = Factory.create(:queued_feed)
      mod_and_run_podcast_processor(qf)
      @podcast = qf.podcast
    end

    def do_get
      get :show, :podcast_slug => @podcast.clean_url
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
      assigns(:podcast).id.should equal(@podcast.id)
    end
  end

  describe "handling DELETE /mypodcast" do
    describe "when user is the podcast owner" do

      before(:each) do
        @user = mock_model(User)
        @podcast = mock_model(Podcast, :destroy => true)
        Podcast.stub!(:find_by_slug).and_return(@podcast)
        @podcast.should_receive(:writable_by?).and_return(true)
        login(@user)
      end

      def do_delete
        delete :destroy, :podcast_slug => 'mypodcast'
      end

      it "should find the podcast requested" do
        Podcast.should_receive(:find_by_slug).with("mypodcast").and_return(@podcast)
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
        @user = Factory.create(:user) #mock_model(User)
        @podcast = Factory.create(:podcast) #mock_model(Podcast, :destroy => true)
        Podcast.stub!(:find).and_return(@podcast)
        @podcast.should_receive(:writable_by?).and_return(false)
        login(@user)
      end

      it "should redirect to the podcasts list" do
        delete :destroy, :podcast_slug => 'mypodcast'
        response.should redirect_to('/')
      end
    end
  end

  describe "handling PUT /:podcast" do
    describe "when user is the podcast owner" do

      def do_put(options={:title => "Custom Title"})
        put :update, :podcast_slug => @podcast.clean_url, :podcast => options
      end

      before(:each) do
        @user = Factory.create(:user)
        @podcast = Factory.create(:parsed_podcast, :state => 'parsed', :owner_email => @user.email, :owner_id => @user.id)

        Podcast.stub!(:find_by_slug).and_return(@podcast)
        @podcast.should_receive(:writable_by?).and_return(true)
        login(@user)
      end

      it "should delete a podcast (via nested form attributes)" do
        podcast_with_nested_attrs = {'_delete' => '1' }
        lambda { do_put(podcast_with_nested_attrs) }.should change{ Podcast.count }.by(-1)
      end

      it "should find the podcast requested" do
        do_put
        assigns(:podcast).id.should == @podcast.id
      end

      it "should update the found podcast" do
        do_put
        assigns(:podcast).reload.title.should == "Custom Title"
      end

      it "should redirect to the podcasts list" do
        do_put
        response.should redirect_to(podcast_url(:podcast_slug => @podcast))
      end

      it "should add a user tagging for tag 'good'" do
        do_put(:tag_string => "good")
        @podcast.reload.tag_string.should == "good"
        @podcast.tags.last.user_taggings.last.user.should == @user
      end
    end

    describe "when user is not authorized" do

      before(:each) do
        @user = Factory.create(:user)
        @podcast = Factory.create(:parsed_podcast)
        Podcast.stub!(:find_by_slug).and_return(@podcast)
        @podcast.should_receive(:writable_by?).and_return(false)
        login(@user)
      end

      it "should redirect to the podcasts list" do
        put :update, :podcast_slug => @podcast.clean_url, :podcast => {:title => "Custom Title"}
        response.should redirect_to('/')
      end
    end

    describe "when user enters malicious params" do

      before(:each) do
        @user = Factory.create(:user)
        @podcast = Factory.create(:podcast, :finder => @user, :owner_email => "test@example.com")
        login(@user)

        put :update, :podcast_slug => @podcast.clean_url, :podcast => {:owner_email => "malicious@example.com"}
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
      xhr :post, :favorite, :podcast_slug => podcast.clean_url
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

    describe "when logged out" do
      before(:each) { logout }

      it "should add unclaimed favorite" do
        lambda { do_post(@podcast) }.should change { @podcast.favorites.count }.by(1)
        assigns(:favorite).user.should be_nil
      end

      it "should add the unclaimed favorite to the session" do
        do_post(@podcast)
        session[:unclaimed_records]['Favorite'].should include(assigns(:favorite).id)
      end

      it "should not add unclaimed favorite if one already exists" do
        favorite = Factory.create(:favorite, :podcast => @podcast, :user => nil)
        @controller.send(:remember_unclaimed_record, favorite)

        lambda {
          lambda {
            do_post(@podcast)
          }.should_not change { @podcast.favorites.count }
        }.should_not change { session[:unclaimed_records]['Favorite'].size }

        session[:unclaimed_records]['Favorite'].size.should == 1
      end
    end
  end








  # specs taken from FeedControllerSpec
  describe "handling GET /add" do
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

    it "should assign the new podcast" do
      do_get
      assigns[:podcast].should be_new_record
    end
  end

  describe "handling POST /podcasts when not logged in" do
    before(:each) do
      post :create, :podcast => {:url => "http://example.com/podcast/feed.xml"}
    end

    it 'should save an unclaimed feed' do
      assigns[:queued_feed].should be_kind_of(QueuedFeed)
      assigns[:queued_feed].should_not be_new_record
      assigns[:queued_feed].user.should be_nil
      QueuedFeed.unclaimed.should include(assigns[:queued_feed])
    end

    it 'should add the feed to the session' do
      session[:unclaimed_records]['QueuedFeed'].should include(assigns[:queued_feed].id)
    end

    it 'should not associate the feed with a user' do
      assigns[:queued_feed].user.should be_nil
    end
  end

  describe "handling POST /podcasts when logged in" do
    before(:each) do
      @user = Factory.create(:user)
      login(@user)
      post :create, :podcast => {:url => "http://example.com/podcast/feed.xml"}
    end

    it 'should save the feed' do
      assigns(:queued_feed).should be_kind_of(QueuedFeed)
      assigns(:queued_feed).should_not be_new_record
    end

    it 'should associate the feed with the user' do
      assigns(:queued_feed).user.should == @user
    end

    it 'should create a feed' do
      assigns(:queued_feed).should be_kind_of(QueuedFeed)
      assigns(:queued_feed).url.should == "http://example.com/podcast/feed.xml"
    end
  end

  describe "POST /status" do
    describe "for a podcast that has not yet been parsed" do
      before(:each) do
        @queued_feed = Factory.create(:queued_feed, :state => nil, :feed => nil)
        post :status, :podcast => @queued_feed.url
      end

      it 'should render the loading template' do
        response.should render_template('podcasts/_status_loading')
      end
    end

    describe "for a podcast that has been parsed" do
      before(:each) do
        @podcast = Factory.create(:podcast)
        @queued_feed = Factory.create(:queued_feed, :podcast => @podcast)

        controller.should_receive(:queued_feed_created_just_now_by_user?).and_return(true)

        post :status, :podcast => @queued_feed.url
      end

      it 'should render the added template' do
        response.should render_template('podcasts/_status_added')
      end
    end

    describe "for a podcast that has failed" do
      describe "because it was not a web address" do
        before(:each) do
          @podcast = Factory.create(:podcast)
          @queued_feed = Factory.create(:queued_feed, :podcast => @podcast, :state => "failed")

          post :status, :podcast => @queued_feed.url
        end

        it 'should render the error template' do
          response.should render_template('podcasts/_status_error')
        end
      end

      describe "because it was not found" do
      end

      describe "because it had a weird server error" do
      end

      describe "because it is on the blacklist" do
      end

      describe "because it is not an RSS feed" do
      end

      describe "because it is a text feed" do
      end
    end
  end

  describe "PUT /podcasts (update)'" do
    describe "when the user is logged in" do
      before do
        @user = Factory.create(:user)
        @podcast = Factory.create(:podcast, :finder => @user, :format => "ipod")

        login(@user)
        put 'update', :podcast_slug => @podcast.to_param, :podcast => {:format => "quicktime hd"}
      end

      it "should update the feed" do
        @podcast.reload.format.should == "quicktime hd"
      end

      it "should redirect to the podcast" do
        response.should redirect_to(podcast_url(@podcast))
      end
    end

    describe "when the user is unauthorized" do
      it "should not update the podcast" do
        @podcast = Factory.create(:podcast, :format => "ipod")
        put 'update', :podcast_slug => @podcast, :podcast => {:format => "quicktime hd"}
        response.should redirect_to('/')
        @podcast.reload.format.should == "ipod"
      end
    end
  end

  describe "DELETE /:podcast_slug (destroy)" do
    describe "when user is logged in" do
      before do
        @user = Factory.create(:user)
        @podcast = Factory.create(:podcast, :finder => @user)

        login(@user)
        @destroy_podcast = lambda { delete :destroy, :podcast_slug => @podcast.clean_url }
      end

      it "should remove the podcast" do
        @destroy_podcast.should change(Podcast, :count).by(-1)
      end

      it 'should redirect to all podcasts' do
        @destroy_podcast.call
        response.should redirect_to(podcasts_url)
      end
    end

    describe "when user is unauthorized" do
      it 'should not delete the podcast' do
        @podcast = Factory.create(:podcast)
        lambda { 
          delete :destroy, :podcast_slug => @podcast.clean_url 
        }.should_not change(Podcast, :count)
        response.should redirect_to('/')
      end
    end
  end
end

