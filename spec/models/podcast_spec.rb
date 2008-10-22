require File.dirname(__FILE__) + '/../spec_helper'

describe Podcast do
  before do
    @podcast = Factory.create(:podcast)
    @user    = Factory.create(:user)
  end

  it "should be valid" do
    @podcast.should be_valid
  end

  it 'should have a logo' do
    @file = PaperClipFile.new
    @podcast.attachment_for(:logo).assign(@file)
    @podcast.logo.should_not be_nil
  end

  it 'should be taggable' do
    @podcast.tag_list = "hi"
    @podcast.save
    @podcast.tags.size.should == 1
  end

  it 'should have a param with the name in it' do
    @podcast.send(:sanitize_url)
    @podcast.clean_url.should == "Podcast"
  end

  it 'should use the custom_title if set' do
    @podcast.title.should == "Podcast"
    @podcast.custom_title = "My Podcast"
    @podcast.custom_title.should == "My Podcast"
    @podcast.custom_title = nil
    @podcast.send(:cache_custom_title)
    @podcast.custom_title.should == "Podcast"
  end
end

describe Podcast, "getting the average time between episodes" do
  before do
    @podcast = Factory.create(:podcast)
    @first = Factory.create(:episode, :podcast_id => @podcast.id, :published_at => 4.days.ago)
  end

  it 'should be zero for only one episode' do
    @podcast.average_time_between_episodes.should == 0
  end

  it 'should be one day for three episodes spaced one day apart' do
    @second =  Factory.create(:episode, :podcast_id => @podcast.id, :published_at => 3.days.ago)
    @third =   Factory.create(:episode, :podcast_id => @podcast.id, :published_at => 2.day.ago)
    @podcast.episodes.count.should == 3
    @podcast.average_time_between_episodes.should be_close(1.day.to_f, 1.minute)
  end

  it 'should be zero for podcasts with no episodes' do
    Factory.create(:podcast).average_time_between_episodes.should == 0
  end
end

describe Podcast, "cleaning up the site url" do
  before do
    @podcast = Factory.create(:podcast)
  end
  
  it 'should remove a leading http://' do
    @podcast.site = "http://test.host"
    @podcast.clean_site.should == "test.host"
  end

  it 'should remove a leading www.' do
    @podcast.site = "www.test.host"
    @podcast.clean_site.should == "test.host"
  end

  it 'should remove both a leading http and www' do
    @podcast.site = "http://www.test.host"
    @podcast.clean_site.should == "test.host"
  end

  it 'should remove a trailing slash' do
    @podcast.site = "http://test.host/"
    @podcast.clean_site.should == "test.host"
  end

  it 'should remove a trailing index.html' do
    @podcast.site = "http://test.host/index.html"
    @podcast.clean_site.should == "test.host"
  end

  it 'should remove trailing parameters' do
    @podcast.site = "http://test.host/podcast/?ref=rss"
    @podcast.clean_site.should == "test.host/podcast"
  end

  it 'should allow for a path' do
    @podcast.site = "http://test.host/path/to/page"
    @podcast.clean_site.should == "test.host/path/to/page"
  end

  it 'should not modify a non-url' do
    @podcast.site = "test.host"
    @podcast.clean_site.should == "test.host"
  end
end

describe Podcast, "generating the clean url" do
  before do
    @podcast = Factory.create(:parsed_podcast)
  end

  it 'should remove leading and trailing whitespaces' do
    @podcast.title = ' title '
    @podcast.send(:sanitize_url).should == 'title'
  end

  it 'should remove non-alphanumeric characters' do
    @podcast.title = ' ^$(title '
    @podcast.send(:sanitize_url).should == 'title'
  end

  it 'should convert interior spaces to dashes' do
    @podcast.title = ' my $title '
    @podcast.send(:sanitize_url).should == 'my-title'
  end
end

describe Podcast, "permissions" do
  describe "an admin" do
    before do
      @user = Factory.create(:admin_user)
      @podcast = Factory.create(:parsed_podcast)
    end
    
    it 'should have write access' do
      @podcast.writable_by?(@user).should == true
    end
  end

  describe "the finder" do
    before do
      @user = Factory.create(:user)
      @podcast = Factory.create(:parsed_podcast, :feeds => [])
      @feed = Factory.create(:feed, :finder_id => @user.id, :podcast => @podcast)
      @podcast.reload
    end

    it 'should have write access' do
      @podcast.writable_by?(@user).should == true
    end

    it 'should not have write access if finder is unconfirmed' do
      @user.state = "pending"
      @podcast.writable_by?(@user).should == false
    end

    it 'should not have write access if there is an owner set' do
      @owner = Factory.create(:user)
      @podcast.update_attribute(:owner_email, @owner.email)
      @podcast.writable_by?(@user).should == false
    end
  end

  describe "the owner" do
    before do
      @user = Factory.create(:user)
      @podcast = Factory.create(:podcast, :owner_email => @user.email)
    end

    it 'should have write access' do
      @podcast.reload
      @podcast.user_is_owner?(@user).should == true
      @podcast.writable_by?(@user).should == true
    end

    it 'should not have write access if owner is unconfirmed' do
      @user.state = "pending"
      @podcast.writable_by?(@user).should == false
    end
  end

  describe "another user" do
    before do
      @user = Factory.create(:user)
      @podcast = Factory.create(:parsed_podcast)
    end
    
    it 'should not have write access' do
      @podcast.writable_by?(@user).should == false
    end
  end
end
