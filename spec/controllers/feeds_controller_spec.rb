require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FeedsController do
  describe "POST 'create'" do
    it "should create the feed"
    it "should add the feed to the podcast" do
      pending
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
