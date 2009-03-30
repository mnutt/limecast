require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FeedsController do

  describe "handling GET /add" do

    before(:each) do
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

    it "should assign the new feed" do
      do_get
      assigns[:feed].should be_new_record
    end
  end

  describe "handling PUT /feeds when not logged in" do
    before(:each) do
      put :create, :feed => {:url => "http://mypodcast/feed.xml"}
    end

    it 'should save an unclaimed feed' do
      assigns[:feed].should be_kind_of(Feed)
      assigns[:feed].should_not be_new_record
      assigns[:feed].finder.should be_nil
      Feed.unclaimed.should include(assigns[:feed])
    end

    it 'should add the feed to the session' do
      session[:unclaimed_records].should include(['Feed', assigns(:feed).id])
    end

    it 'should not associate the feed with a user' do
      assigns[:feed].finder.should be_nil
    end
  end

  describe "handling POST /feeds when logged in" do
    before(:each) do
      @user = Factory.create(:user)
      login(@user)
      post :create, :feed => {:url => "http://mypodcast/feed.xml"}
    end

    it 'should save the feed' do
      assigns(:feed).should be_kind_of(Feed)
      assigns(:feed).should_not be_new_record
    end

    it 'should associate the feed with the user' do
      assigns(:feed).finder.should == @user
    end

    it 'should create a feed' do
      assigns(:feed).should be_kind_of(Feed)
      assigns(:feed).url.should == "http://mypodcast/feed.xml"
    end
  end

  describe "POST /status" do
    describe "for a podcast that has not yet been parsed" do
      before(:each) do
        @podcast = Factory.create(:podcast)
        post :status, :feed => @podcast.feeds.first.url
      end

      it 'should render the loading template' do
        response.should render_template('feeds/_status_loading')
      end
    end

    describe "for a podcast that has been parsed" do
      before(:each) do
        @podcast = Factory.create(:parsed_podcast)
        controller.should_receive(:feed_created_just_now_by_user?).and_return(true)

        post :status, :feed => @podcast.feeds.first.url
      end

      it 'should render the added template' do
        response.should render_template('feeds/_status_added')
      end
    end

    describe "for a podcast that has failed" do
      describe "because it was not a web address" do
        before(:each) do
          @podcast = Factory.create(:failed_podcast)
          post :status, :feed => @podcast.feeds.first.url
        end

        it 'should render the error template' do
          response.should render_template('feeds/_status_failed')
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

  describe "PUT 'update'" do
    describe "when the user is logged in" do
      before do
        @user = Factory.create(:user)
        @feed = Factory.create(:feed, :finder => @user, :format => "ipod")

        login(@user)
        put 'update', :id => @feed.id, :feed => {:format => "quicktime hd"}
      end

      it "should update the feed" do
        @feed.reload.format.should == "quicktime hd"
      end

      it "should return a 200 response" do
        response.should be_success
      end
    end

    describe "when the user is unauthorized" do
      it "should not update the feed" do
        @feed = Factory.create(:feed, :format => "ipod")
        put 'update', :id => @feed.id, :feed => {:format => "quicktime hd"}
        flash[:notice].should == 'Sorry, you are not allowed to access that page.'
        response.should redirect_to('/')
        @feed.reload.format.should == "ipod"
      end
    end
  end

  describe "DELETE 'destroy'" do
    describe "when user is logged in" do
      before do
        @user = Factory.create(:user)
        @feed = Factory.create(:feed, :finder => @user)

        Feed.count.should == 1

        login(@user)
        delete 'destroy', :id => @feed.id
      end

      it "should remove the feed" do
        Feed.count.should == 0
      end

      it 'should return a 200 response' do
        response.should be_success
      end
    end

    describe "when user is unauthorized" do
      it 'should not delete the feed' do
        @feed = Factory.create(:feed)
        delete 'destroy', :id => @feed.id
        flash[:notice].should == 'Sorry, you are not allowed to access that page.'
        response.should redirect_to('/')
        Feed.count.should == 1
      end
    end
  end
end
