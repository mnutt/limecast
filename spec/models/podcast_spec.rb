require File.dirname(__FILE__) + '/../spec_helper'

describe Podcast do
  before do
    @user    = Factory.create(:user, :login => "podcast_spec_user")
    @podcast = Factory.create(:podcast, :xml_title => "My Podcast")
  end

  it "should be valid" do
    @podcast.should be_valid
  end

  it 'should have a param with the name in it' do
    @podcast.clean_url.should == "My-Podcast"
  end

  it 'should use the primary_feed title if set' do
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
    @podcast.reload.episodes.count.should == 3
    @podcast.average_time_between_episodes.should be_close(1.day.to_f, 5.minutes)
  end

  it 'should be zero for podcasts with no episodes' do
    f = Factory.create(:podcast)
    f.average_time_between_episodes.should == 0
  end
end

describe Podcast, 'sorting' do
  before do
    ["S Podcast", "O Podcast", "The Podcast", "A Podcast", "Z Podcast"].map {|name|
      Factory.create(:podcast, :title => name)
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

describe Podcast, "with duplicate titles" do
  before do 
    @podcast = Factory.create(:podcast, :xml_title => "Spectacular Spectacular")
    @podcast2 = Factory.create(:podcast, :xml_title => "Spectacular Spectacular")
  end

  it 'should increment the title' do
    @podcast.title.should == "Spectacular Spectacular"
    @podcast2.title.should == "Spectacular Spectacular 2"
  end
  
  it 'should increment the url as well' do
    @podcast.clean_url.should == "Spectacular-Spectacular"
    @podcast2.clean_url.should == "Spectacular-Spectacular-2"
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

  it "should not add extra hyphens" do
    @podcast.title = "Advice Line with Roy Masters - Radio Archive | Blog Talk Radio Feed"
    @podcast.send(:sanitize_url).should == "Advice-Line-with-Roy-Masters-Radio-Archive-Blog-Talk-Radio-Feed"
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
      @podcast = Factory.create(:parsed_podcast, :finder_id => @user.id, :url => "#{Factory.next(:site)}/feed.xml")
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
      @user.confirm
      @user.save
    end

    it 'should have write access' do
      @podcast.user_is_owner?(@user).should == true
      @podcast.writable_by?(@user).should == true
    end

    it 'should NOT have write access if owner is unconfirmed' do
      @user.state = "pending"
      @podcast.should_not be_writable_by(@user)
    end

    it 'should create the owner User if not found' do
      create_podcast = lambda { p = Factory.create(:podcast, :owner_email => 'foobar@baz.com') }
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
      @finder = Factory.create(:user)
      @admin = Factory.create(:admin_user)
      @podcast = Factory.create(:podcast, :owner_email => "the.owner@email.com", :finder_id => @finder.id)
      @owner = @podcast.owner
    end

    # Gods can edit everything
    # A user can edit himself
    # If the podcast is not protected, the podcast's finder can edit the podcast and its episodes
    # If the email is confirmed, the podcast's maker can edit the podcast and its episodes

    it "should include admins" do
      @podcast.editors.should include(@admin)
    end

    it "should include the confirmed finder" do
      @podcast.editors.should include(@finder)
    end

    it "should not include the finder" do
      @podcast.update_attribute(:protected, true)
      @podcast.editors.should_not include(@finder)
    end

    it "should not include a passive finder" do
      @finder.update_attribute(:state, 'passive')
      @podcast.editors.should_not include(@owner)
    end

    it "should not include a passive owner" do
      @podcast.editors.should_not include(@owner)
    end

    it "should include a confirmed owner" do
      @owner.update_attribute(:state, 'confirmed')
      @podcast.editors.should include(@owner)
    end
  end
end

describe Podcast, "primary feed" do
  before do
    @podcast = Factory.create(:parsed_podcast)
    @feed = Factory.create(:feed, :state => "parsed")
    @feed2 = Factory.create(:feed, :state => "parsed")
    @podcast.feeds << @feed
    @podcast.feeds << @feed2
  end

  it 'should have the first feed be the primary feed' do
    @podcast.primary_feed.should == @feed
  end

  it 'should make the second feed be the primary feed' do
    @podcast.update_attribute(:primary_feed_id, @feed2.id)
    @podcast.primary_feed.should == @feed2
    @feed2.reload
    @feed2.should be_primary
  end
end

describe Podcast, "additional badges" do
  before(:each) do
    @podcast = Factory.create(:parsed_podcast, :language => 'es')
  end

  it "should include language" do
    @podcast.additional_badges.should include('es')
    @podcast.update_attribute(:language, 'jp')
    @podcast.additional_badges(true).should include('jp')
  end

  it "should include 'current'" do
    Episode.create(:published_at => 29.day.ago, :podcast_id => @podcast.id)
    @podcast.reload.additional_badges.should include("current")
  end

  it "should include 'stale'" do
    Episode.create(:published_at => 31.day.ago, :podcast_id => @podcast.id)
    @podcast.reload.additional_badges.should include("stale")
  end

  it "should include 'archive'" do
    Episode.create(:published_at => 91.day.ago, :podcast_id => @podcast.id)
    @podcast.reload.additional_badges.should include("archive")
  end
end

describe Podcast, "taggers" do
  before(:each) do
    @podcast = Factory.create(:podcast)
    @user1 = Factory.create(:user)
    @user2 = Factory.create(:user)
    @user3 = Factory.create(:user)
  end

  it "should be empty if podcast isn't tagged" do
    @podcast.taggers.should be_empty
  end

  it "should only include the users who tagged it" do
    @podcast.tag_string = ["somebadge"]
    @podcast.tag_string = ["fromuser1", @user1]
    @podcast.tag_string = ["fromuser2", @user2]
    @podcast.reload.taggers.should == [@user1, @user2]
  end
end

describe Podcast, "detecting LimeTracker" do
  before do
    @podcast = Factory.create(:podcast, :generator => "limecast.com/tracker")
    @podcast2 = Factory.create(:podcast, :generator => "http://limecast.com/tracker")
    @podcast3 = Factory.create(:podcast, :generator => "something else")
  end

  it "should select all LimeTracker feeds" do
    Podcast.from_limetracker.all.should == [@podcast, @podcast2]
  end
end


describe Podcast, "finding or creating owner" do
  before do
    @podcast = Factory.build(:podcast, :title => "FOoooooobar", :owner_email => "some.owner@here.com")
    @save_podcast = lambda { @podcast.save }
  end

  it "should set and create the passive owner if the owner doesn't exist" do
    @save_podcast.should change { User.all.size }.by(1)
    @podcast.owner.should == User.last
    @podcast.owner.should be_passive
  end

  it "should find and set the owner if owner exists" do
    owner = Factory.create(:user, :email => @podcast.owner_email)
    @save_podcast.should_not change { User.all.size }
    @podcast.owner.should == owner
  end
end