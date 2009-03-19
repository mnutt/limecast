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
        flash[:notice].should == 'Sorry, you are not allowed to access that page.'
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
        @podcast = Factory.create(:parsed_podcast, :owner_email => @user.email, :owner_id => @user.id)
        @feed = Factory.create(:feed, :state => 'parsed')
        Podcast.stub!(:find_by_slug).and_return(@podcast)
        @podcast.should_receive(:writable_by?).and_return(true)
        login(@user)
      end

      it "should add a new feed (via nested form attributes)" do
        # the nested attributes should build a new association model for every hash that doesn't have an id 
        url = "http://#{@podcast.clean_site}/newfeed.xml"
        podcast_with_nested_attrs = {'feeds_attributes' => {'new' => {"url" => url}}}
        lambda { do_put(podcast_with_nested_attrs) }.should change{ @podcast.reload.feeds.size }.by(1)
        @podcast.feeds.find_by_url(url).finder.should == @user
      end

      it "should delete a feed (via nested form attributes)" do
        podcast_with_nested_attrs = {'feeds_attributes' => {"0" => {"id" => @podcast.feeds.first.id.to_s, "_delete" => "1"}}}
        lambda { do_put(podcast_with_nested_attrs) }.should change{ @podcast.reload.feeds.size }.by(-1)
      end

      it "should delete a podcast (via nested form attributes)" do
        podcast_with_nested_attrs = {'_delete' => '1' }
        lambda { do_put(podcast_with_nested_attrs) }.should change{ Podcast.count }.by(-1)
      end

      it "should send notifications to admins/finders/owners after a podcast is updated" do
        ActionMailer::Base.deliveries = []
        lambda { do_put(:title => "Foobarbaz") }.should change { ActionMailer::Base.deliveries.size }.by(@podcast.editors.size)
        @podcast.reload.title.should == "Foobarbaz"
        ActionMailer::Base.deliveries.last.body.should =~ /A podcast that you can edit has been changed./
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

      it "should make a feed the primary feed" do
        do_put(:primary_feed_id => @feed.id)
        @podcast.reload.primary_feed.should == @feed
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
        flash[:notice].should == 'Sorry, you are not allowed to access that page.'
      end
    end

    describe "when user enters malicious params" do

      before(:each) do
        @user = Factory.create(:user)
        @podcast = Factory.create(:podcast, :feeds => [Factory.create(:feed, :finder => @user)], :owner_email => "test@example.com")
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
  end

  describe "handling POST /:podcast/tag" do
    before do
      @user = Factory.create(:user)
      @podcast = Factory.create(:podcast)
    end
    
    def do_put(podcast=nil, tag_string="foobar")
      put :tag, :podcast_slug => @podcast.clean_url, :podcast => {:tag_string => tag_string}
    end

    describe "logged in" do
      before do
        login @user
      end

      it "should be redirect to podcast" do
        do_put(@podcast).should redirect_to(podcast_url(@podcast))
      end
    
      it "should increment the taggings count by 1" do
        lambda { do_put(@podcast) }.should change { @podcast.taggings.count }.by(1)
      end
    
      it "should increment the taggings count by 4" do
        lambda { do_put(@podcast, "one two three four") }.should change { @podcast.taggings.count }.by(4)
      end

      it "should strip spaces if commas are used" do
        lambda { do_put(@podcast, "blaster master, zelda") }.should change { @podcast.taggings.count }.by(3)
        @podcast.tags.map(&:name).should include("blaster")
        @podcast.tags.map(&:name).should include("master")
        @podcast.tags.map(&:name).should include("zelda")
      end
    end
    
    describe "not logged in" do
      it "should redirect to home" do
        do_put(@podcast).should redirect_to('/')
      end
      
      it "should not change the taggings count" do
        lambda { do_put(@podcast, "five six seven eight") }.should change { @podcast.taggings.count }.by(0)
      end
    end
  end

end
