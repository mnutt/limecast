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

  describe "handling GET /:podcast/cover" do
    before(:each) do
      @podcast = Factory.create(:parsed_podcast)
      get :cover, :podcast_slug => @podcast.clean_url
    end

    it 'should assign the podcast' do
      assigns(:podcast).should == @podcast
    end

    it 'should render the cover template' do
      response.should render_template('podcasts/cover')
    end
  end

  describe "handling DELETE /mypodcast" do
    describe "when user is the podcast owner" do

      before(:each) do
        @user = mock_model(User)
        @podcast = mock_model(Podcast, :destroy => true)
        Podcast.stub!(:find_by_clean_url).and_return(@podcast)
        @podcast.should_receive(:writable_by?).and_return(true)
        login(@user)
      end

      def do_delete
        delete :destroy, :podcast_slug => 'mypodcast'
      end

      it "should find the podcast requested" do
        Podcast.should_receive(:find_by_clean_url).with("mypodcast").and_return(@podcast)
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
        flash[:notice].should == 'Sorry, you are not allowed to access that page.'
      end
    end
  end

  describe "handling POST /:podcast" do
    describe "when user is the podcast owner" do

      def do_post(options={:title => "Custom Title"})
        post :update, :podcast_slug => @podcast.clean_url, :podcast => options
      end

      before(:each) do
        @user = Factory.create(:user)
        @podcast = Factory.create(:parsed_podcast)
        @feed = Factory.create(:feed, :state => 'parsed')
        Podcast.stub!(:find_by_clean_url).and_return(@podcast)
        @podcast.should_receive(:writable_by?).and_return(true)
        login(@user)
      end

      it "should find the podcast requested" do
        do_post
        assigns(:podcast).id.should == @podcast.id
      end

      it "should update the found podcast" do
        do_post
        assigns(:podcast).reload.title.should == "Custom Title"
      end

      it "should redirect to the podcasts list" do
        do_post
        response.should redirect_to(podcast_url(:podcast_slug => @podcast))
      end

      it "should make a feed the primary feed" do
        do_post(:primary_feed_id => @feed.id)
        @podcast.reload.primary_feed.should == @feed
      end
      
      it "should add a user tagging for tag 'good'" do
        do_post(:tag_string => "good")
        @podcast.reload.tag_string.should == "good"
        puts "\n\nThe podcast tags here are #{@podcast.tags.last.user_taggings.inspect}"
        puts "The podcast tag_string here is #{@podcast.tag_string}\n\n"
        @podcast.tags.last.user_taggings.last.user.should == @user
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
        post :update, :podcast_slug => @podcast.clean_url, :podcast => {:title => "Custom Title"}
        response.should redirect_to('/')
        flash[:notice].should == 'Sorry, you are not allowed to access that page.'
      end
    end

    describe "when user enters malicious params" do

      before(:each) do
        @user = Factory.create(:user)
        @podcast = Factory.create(:podcast, :feeds => [Factory.create(:feed, :finder => @user)], :owner_email => "test@example.com")
        login(@user)

        post :update, :podcast_slug => @podcast.clean_url, :podcast => {:owner_email => "malicious@example.com"}
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
  end

end
