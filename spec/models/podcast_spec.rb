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
  pending "fix weird CI problem"
    @second =  Factory.create(:episode, :podcast_id => @podcast.id, :published_at => 3.days.ago)
    @third =   Factory.create(:episode, :podcast_id => @podcast.id, :published_at => 2.day.ago)
    @podcast.episodes.count.should == 3
    @podcast.average_time_between_episodes.should be_close(1.day.to_f, 5.minutes)
  end

  it 'should be zero for podcasts with no episodes' do
    Factory.create(:podcast).average_time_between_episodes.should == 0
  end
end

describe Podcast, 'sorting' do
  before do
    @podcasts = ["S Podcast", "O Podcast", "The Podcast", "A Podcast", "Z Podcast"].map {|name| Factory.create(:podcast, :title => name) }
  end

  it 'should not sort on the word "The"' do
    titles = Podcast.sorted.map &:title
    titles.should == ["A Podcast", "O Podcast", "The Podcast", "S Podcast", "Z Podcast"]
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

describe Podcast, "cleaning up the title" do
  before do
    @podcast = Factory.create(:podcast)
  end

  it 'should remove things in parentheses' do
    @podcast.title = "Podcast (junk)"
    @podcast.send(:sanitize_title).should == "Podcast"
  end

  it 'should remove extra space' do
    @podcast.title = " Podcast "
    @podcast.send(:sanitize_title).should == "Podcast"
  end

  it 'should remove leading dashes' do
    @podcast.title = " - Podcast"
    @podcast.send(:sanitize_title).should == "Podcast"
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

describe Podcast, "being saved with tag_string" do
  before do
    @podcast = Factory.create(:podcast)
  end

  it 'should create tags' do
    lambda {
      @podcast.update_attributes(:tag_string => "tag1 tag2 tag3")
    }.should change(Tag, :count).by(3)
  end
end

describe Podcast, "with associated tags" do
  before do
    @podcast1 = Factory.create(:podcast, :tag_string => "tag1 commontag")
    @podcast2 = Factory.create(:podcast, :tag_string => "tag2 commontag")
  end

  it 'should be able to find all podcasts with a common tag' do
    podcasts = Podcast.tagged_with("commontag")
    podcasts.should include(@podcast1)
    podcasts.should include(@podcast2)
  end

  it 'should be able to find a podcast with a unique tag' do
    podcasts = Podcast.tagged_with("tag1")
    podcasts.should     include(@podcast1)
    podcasts.should_not include(@podcast2)

    podcasts = Podcast.tagged_with("tag2")
    podcasts.should_not include(@podcast1)
    podcasts.should     include(@podcast2)
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

describe Podcast, "with associated feeds" do
  before do
    @podcast = Factory.create(:parsed_podcast)
    @podcast2 = Factory.create(:failed_podcast)
    @feed = Factory.create(:feed, :state => "parsed")
  end

  it 'should not be failed? if has all parsed feeds' do
    @podcast.should_not be_failed
  end

  it 'should be failed? if has all failed feeds' do
    @podcast2.should be_failed
  end

  it 'should not be failed? if has parsed feeds and failed feeds' do
    @podcast2.feeds << @feed
    @podcast2.should_not be_failed
  end
end

describe Podcast, "primary feed" do
  before do
    @podcast = Factory.create(:parsed_podcast)
    @feed = @podcast.feeds.first
    @feed2 = Factory.create(:feed, :state => "parsed")
    @podcast.feeds << @feed2
  end
  
  it 'should have the first feed be the primary feed' do
    @podcast.primary_feed.should == @feed
  end
  
  it 'should make the second feed be the primary feed' do
    @podcast.update_attribute(:primary_feed_id, @feed2.id)
    @podcast.primary_feed.should == @feed2
    @feed2.should be_primary
  end
end
