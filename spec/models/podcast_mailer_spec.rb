require File.dirname(__FILE__) + '/../spec_helper'

# Be sure to include AuthenticatedTestHelper in spec/spec_helper.rb instead.
# Then, you can remove it from this and the functional test.
include AuthenticatedTestHelper

describe PodcastMailer do
  before do
    @finder = Factory.create(:user, :email => "somefinder@limewire.com")
    @admin = Factory.create(:admin_user, :email => "someadmin@limewire.com")
    @owner = Factory.create(:user, :email => "someowner@limewire.com")
    @podcast = Factory.create(:parsed_podcast, 
      :owner_id => @owner.id, :owner_email => @owner.email, :site => 'somewhere.com', 
      :feeds => [Factory.create(:feed, :url => "http://somewhere.com/feed.xml", :content => File.open("#{RAILS_ROOT}/spec/data/example.xml").read, :state => 'parsed', :finder_id => @finder.id)])
  end

  before(:each) do
    setup_actionmailer
  end


  it 'should send an "updated podcast from site" email' do
    lambda { PodcastMailer.deliver_updated_podcast_from_site(@podcast) }.should change { ActionMailer::Base.deliveries.size }.by(1)
    ActionMailer::Base.deliveries.last.to_addrs.map { |to| to.to_s }.should == @podcast.editors.map(&:email)
    ActionMailer::Base.deliveries.last.subject.should == 'A podcast you can edit was changed.'
    ActionMailer::Base.deliveries.last.body.should =~ /A podcast that you can edit has been changed/
  end

  it 'should send an "updated podcast from feed" email' do
    lambda { PodcastMailer.deliver_updated_podcast_from_feed(@podcast) }.should change { ActionMailer::Base.deliveries.size }.by(1)
    ActionMailer::Base.deliveries.last.to_addrs.map { |to| to.to_s }.should == @podcast.editors.map(&:email)
    ActionMailer::Base.deliveries.last.subject.should == 'A podcast you can edit was changed.'
    ActionMailer::Base.deliveries.last.body.should =~ /A podcast that you can edit has been updated because one of its feeds was changed/
  end

  describe "for emails outside of limewire.com" do # sanity check before launch
    before do
      @finder.update_attribute(:email, "somefinder@external.domain.com")
    end

    it 'should not "updated podcast from site" email to emails outside of limewire.com' do
      PodcastMailer.deliver_updated_podcast_from_site(@podcast)
      ActionMailer::Base.deliveries.last.to_addrs.map(&:to_s).should_not include(@finder.email)
    end

    it 'should not "updated podcast from feed" email to emails outside of limewire.com' do
      PodcastMailer.deliver_updated_podcast_from_feed(@podcast)
      ActionMailer::Base.deliveries.last.to_addrs.map(&:to_s).should_not include(@finder.email)
    end
  end

  after(:each) do
    reset_actionmailer
  end
end

