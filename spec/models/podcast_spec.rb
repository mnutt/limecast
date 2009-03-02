require File.dirname(__FILE__) + '/../spec_helper'

describe Podcast do
  before do
    @user    = Factory.create(:user)
    @podcast = Factory.create(:podcast, :original_title => "My Podcast")
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
    @podcast.clean_url.should == "My-Podcast"
  end

  it 'should use the original_title if set' do
    @podcast.title.should == "My Podcast"
  end
  
  it "should not be valid with no alphanumeric chars" do
    @podcast.title = "?????"
    @podcast.should_not be_valid
    @podcast.errors.on(:title).should include("must include at least 1 letter (a-z, A-Z)")
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
    @podcast.average_time_between_episodes.should be_close(1.day.to_f, 5.minutes)
  end

  it 'should be zero for podcasts with no episodes' do
      f = Factory.create(:podcast)
      f.average_time_between_episodes.should == 0
  end
end

describe Podcast, 'sorting' do
  before do
    @podcasts = ["S Podcast", "O Podcast", "The Podcast", "A Podcast", "Z Podcast"].map {|name| 
      @podcast = Factory.create(:podcast, :title => name)
    }
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
  
  it 'should return blank for an empty site' do
    @podcast.site = nil
    @podcast.clean_site.should == ""
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

describe Podcast, "being saved with tag_string from users" do
  before do
    @user = Factory.create(:user)
    @user2 = Factory.create(:user)
    @podcast = Factory.create(:podcast)
  end

  it 'should create tags and the user taggings' do
    lambda {
      @podcast.update_attributes(:tag_string => ["tag1 tag2 tag3", @user])
    }.should change(Tag, :count).by(3)

    tagging = Tagging.find_by_podcast_id_and_tag_id(@podcast.id, @user.id)
    @user.user_taggings.reload.map { |ut| ut.tag.name }.should == %w(tag1 tag2 tag3)
    @user.user_taggings.reload.map { |ut| ut.podcast.id }.should == [@podcast.id, @podcast.id, @podcast.id]
  end

  it 'should create a tag from multiple users' do
    lambda {
      @podcast.update_attributes(:tag_string => ["tag1", @user])
    }.should change(Tag, :count).by(1)
    lambda {
      @podcast.update_attributes(:tag_string => ["tag1", @user2])
    }.should change(Tag, :count).by(0)
    
    tag = Tag.find_by_name('tag1')
    tag.taggings.find_by_podcast_id(@podcast.id).user_taggings.map(&:user_id).should == [@user.id, @user2.id]
  end
end

describe Podcast, "with associated tags" do
  before do
    @podcast1 = Factory.create(:podcast)
    @podcast2 = Factory.create(:podcast)

    @podcast1.tag_string = "tag1 commontag"
    @podcast2.tag_string = "tag2 commontag"
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
      @feed = Factory.create(:feed, :finder_id => @user.id, :podcast => @podcast, :url => "#{@podcast.site}/feed.xml")
      @podcast.reload
    end

    it 'should have write access' do
      @podcast.writable_by?(@user).should == true
    end

    it 'should have write access even if finder is unconfirmed' do
      @user.state = "pending"
      @podcast.writable_by?(@user).should == true
    end

    it 'should have write access even if there is an owner set' do
      @owner = Factory.create(:user)
      @podcast.update_attribute(:owner_email, @owner.email)
      @podcast.writable_by?(@user).should == true
    end
  end

  describe "the owner" do
    before do
      @podcast = Factory.create(:podcast)
      @user = @podcast.owner
    end

    it 'should have write access' do
      @podcast.reload
      @podcast.user_is_owner?(@user).should == true
      @podcast.writable_by?(@user).should == true
    end

    it 'should have write access if owner is unconfirmed' do
      @user.state = "pending"
      @podcast.should be_writable_by(@user)
    end

    it 'should create the owner User if not found' do
      create_podcast = lambda { Podcast.create(:owner_email => 'foobar@baz.com', :original_title => 'foobar podcast') }
      create_podcast.should change { User.count }.by(1)
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

  describe "all editors" do
    before do
      @owner = Factory.create(:user, :login => "owner")
      @finder = Factory.create(:user, :login => "finder")
      @admin = Factory.create(:admin_user)
      @podcast = Factory.create(:podcast, :owner_id => @owner.id)
      @podcast.feeds.first.update_attribute(:finder_id, @finder.id)
    end

    it "should include the finders using finders()" do
      @podcast.finders.should == [@finder]
    end

    it "should be returned by editors()" do
      @podcast.editors.should == [@admin, @finder, @owner]
    end
    
    it "should not include passive users" do
      @podcast.owner.update_attribute(:state, :passive)
      @podcast.editors.should_not include(@podcast.owner)
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

describe Podcast, "finding or creating owner" do
  before do
    @podcast = Factory.build(:podcast)
    @save_podcast = lambda { @podcast.save }
  end

  it "should set and create the passive owner if the owner doesn't exist" do
    @save_podcast.should change { User.all.size }.by(1)
    @podcast.owner.should == User.last
    @podcast.owner.should be_passive
  end

  it "should find and set the owner if owner exists" do
    @podcast.owner = user = Factory.create(:user, :email => 'john.doe@example.com')
    @save_podcast.should_not change { User.all.size }
    @podcast.owner.should == user
  end
  
  describe 'email notifications' do
    # Sending all to Kevin until launch
    it 'should send podcast notification if owner already existed' do
      setup_actionmailer
      user = Factory.create(:user, :email => 'john.doe@example.com')
      @podcast.owner_email = user.email
      @save_podcast.should change { ActionMailer::Base.deliveries.size }.by(1)
      @podcast.owner.should == user
      ActionMailer::Base.deliveries.first.to_addrs[0].to_s.should == 'kfaaborg@limewire.com' # @podcast.owner.email
      ActionMailer::Base.deliveries.first.body.should =~ /Someone added your podcast to LimeCast/
      reset_actionmailer
    end
    
    it 'should NOT send podcast notification if owner did not already exist or was passive' do
      setup_actionmailer
      User.exists?(:email => @podcast.owner_email).should be(false)
      @save_podcast.should_not change { ActionMailer::Base.deliveries.size }
      reset_actionmailer
    end
  end
end