require File.dirname(__FILE__) + '/../spec_helper'

# Be sure to include AuthenticatedTestHelper in spec/spec_helper.rb instead.
# Then, you can remove it from this and the functional test.
include AuthenticatedTestHelper

describe User do
  before do
    @user = Factory.create(:user)
  end

  describe 'commenting on an Episode' do
    it 'should increase score' do
      lambda do
        Factory.create(:review, :reviewer => @user)
      end.should change { @user.score }.by(1)
    end
  end

  describe 'adding a Feed' do
    it 'should increase score' do
      lambda do
        @podcast = Factory.create(:parsed_podcast, :feeds => [])
        @feed = Factory.create(:feed,
                               :finder => @user,
                               :state => 'parsed',
                               :url => "#{@podcast.site}/feed.xml",
                               :podcast_id => @podcast.id)
        @feed.update_finder_score
      end.should change { @user.score }.by(1)
    end
  end

  describe 'being created' do
    it 'increments User#count' do
      lambda { Factory.create(:user) }.should change(User, :count).by(1)
    end

    it 'should fail when login field has "@"' do
      lambda {
        Factory.create(:user, :login => "thisisalogin@me")
      }.should raise_error(ActiveRecord::RecordInvalid)
    end
  end

  it 'should require login' do
    lambda { u = Factory.create(:user, :login => nil) }.should raise_error(ActiveRecord::RecordInvalid)
  end

  it 'requires password' do
    lambda { u = Factory.create(:user, :password => nil) }.should raise_error(ActiveRecord::RecordInvalid)
  end

  it 'requires email' do
    lambda { u = Factory.create(:user, :email => nil) }.should raise_error(ActiveRecord::RecordInvalid)
  end

  describe 'reseting password' do
    it 'should still authenticate user' do
      @user.update_attributes!(:password => 'new password')
      User.authenticate(@user.email, 'new password').should == @user
    end
  end

  it 'should not rehash password when updating a field' do
    @user.update_attributes!(:email => 'this_is_my_new_login@gmail.com')
    User.authenticate('this_is_my_new_login@gmail.com', 'password').should == @user
  end

  it 'should authenticate user with email' do
    User.authenticate(@user.email, "password").should == @user
  end

  it 'should authenticate user with login name' do
    User.authenticate(@user.login, "password").should == @user
  end

  it 'sets remember token' do
    @user.remember_me
    @user.remember_token.should_not be_nil
    @user.remember_token_expires_at.should_not be_nil
  end

  it 'unsets remember token' do
    @user.remember_me
    @user.remember_token.should_not be_nil
    @user.forget_me
    @user.remember_token.should be_nil
  end

  it 'remembers me for one week' do
    before = 1.week.from_now.utc
    @user.remember_me_for 1.week
    after = 1.week.from_now.utc
    @user.remember_token.should_not be_nil
    @user.remember_token_expires_at.should_not be_nil
    @user.remember_token_expires_at.between?(before, after).should be_true
  end

  it 'remembers me until one week' do
    time = 1.week.from_now.utc
    @user.remember_me_until time
    @user.remember_token.should_not be_nil
    @user.remember_token_expires_at.should_not be_nil
    @user.remember_token_expires_at.should == time
  end

  it 'remembers me default two weeks' do
    before = 2.weeks.from_now.utc
    @user.remember_me
    after = 2.weeks.from_now.utc
    @user.remember_token.should_not be_nil
    @user.remember_token_expires_at.should_not be_nil
    @user.remember_token_expires_at.between?(before, after).should be_true
  end

  describe 'email notifications' do
    before(:each) do
      setup_actionmailer
    end

    it 'should send welcome email after a pending user is created' do
      user = Factory.build(:user, :login => 'mylogin', :state => 'passive')
      user.register!
      user.save
      ActionMailer::Base.deliveries.size.should == 1
      ActionMailer::Base.deliveries.first.to_addrs[0].to_s.should == user.email
      ActionMailer::Base.deliveries.first.body.should =~ /Your LimeCast account has been created/
      ActionMailer::Base.deliveries.first.body.should =~ /Visit this url to activate your account/
    end

    it 'should NOT send welcome email after a passive user is created' do
      Factory.create(:user, :login => 'mylogin', :state => 'passive')
      ActionMailer::Base.deliveries.size.should == 0
    end

    it 'should NOT send welcome email after an active user is created' do
      Factory.create(:user, :login => 'mylogin', :state => 'active')
      ActionMailer::Base.deliveries.size.should == 0
    end
    
    it 'should send reconfirm email and change state to passive after active email is changed' do
      user = Factory.create(:user)
      change_email = lambda { user.update_attribute(:email, 'my.new.email.address@foobar.com') }
      change_email.should change { ActionMailer::Base.deliveries.size }.by(1)
      user.should be_pending
      ActionMailer::Base.deliveries.first.to_addrs[0].to_s.should == 'my.new.email.address@foobar.com'
      ActionMailer::Base.deliveries.first.subject.should == 'Please reconfirm your email address'
      ActionMailer::Base.deliveries.first.body.should =~ /Visit this url to reconfirm your email/
    end

    it 'should NOT send reconfirm email and change state to passive after pending email is changed' do
      user = Factory.create(:pending_user)
      change_email = lambda { user.update_attribute(:email, 'my.new.email.addresssss@foobar.com') }
      change_email.should_not change { ActionMailer::Base.deliveries.size }
    end

    it 'should NOT send reconfirm email and change state to passive after pending email is changed' do
      user = Factory.create(:user, :state => 'passive')
      change_email = lambda { user.update_attribute(:email, 'my.new.email.addresssss@foobar.com') }
      change_email.should_not change { ActionMailer::Base.deliveries.size }
    end

    after(:each) do
      reset_actionmailer
    end
  end
end

