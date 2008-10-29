require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FeedsController do
  describe "POST 'create'" do
    before(:each) do
      @user = Factory.create(:user)
      @podcast = Factory.create(:podcast)
      login(@user)
      post :create, :feed => {:podcast_id => @podcast.id, :url => "http://mysite.com/feed.xml" }
    end

    it "should create the feed" do
      assigns(:feed).should be_kind_of(Feed)
      assigns(:feed).should_not be_new_record
    end

    it "should add the feed to the podcast" do
      assigns(:feed).podcast.should == @podcast
    end

    it "should associate the feed with the user" do
      assigns(:feed).finder.should == @user
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
        lambda {
          put 'update', :id => @feed.id, :feed => {:format => "quicktime hd"}
        }.should raise_error(Forbidden)
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
        lambda {
          delete 'destroy', :id => @feed.id
        }.should raise_error(Forbidden)
        Feed.count.should == 1
      end
    end
  end
end
