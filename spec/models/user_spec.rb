require File.dirname(__FILE__) + '/../spec_helper'

# Be sure to include AuthenticatedTestHelper in spec/spec_helper.rb instead.
# Then, you can remove it from this and the functional test.
include AuthenticatedTestHelper

describe User do
  before do
    @user = Factory.create(:user)
  end

  describe 'commenting on a Podcast' do
    it 'should increase score' do
      lambda do
        Factory.create(:review, :reviewer => @user)
      end.should change { @user.score }.by(1)
    end
  end

  describe 'adding a Podcast' do
    it 'should increase score' do
      lambda do
        @podcast  = Factory.create(:parsed_podcast)
        @podcast2 = Factory.create(:parsed_podcast, :finder => @user)
        @podcast2.send(:update_finder_score)
      end.should change { @user.reload.score }.by(1)
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

  it 'should not require login' do
    lambda { u = Factory.create(:user, :login => nil) }.should_not raise_error
  end

  it 'should set the login to 1st part of email if blank' do
    Factory.create(:user, :email => "ton-ton@hoth.com", :login => nil).login.should == "ton-ton"
  end

  it 'should increment the login when autosetting if login exists' do
    Factory.create(:user, :email => "ton-ton@hoth.com", :login => nil).login.should == "ton-ton"
    Factory.create(:user, :email => "ton-ton@hooth.com", :login => nil).login.should == "ton-ton2"
    Factory.create(:user, :email => "ton-ton@hoooth.com", :login => nil).login.should == "ton-ton3"
    Factory.create(:user, :email => "ton-ton@hooooth.com", :login => nil).login.should == "ton-ton4"
  end

  it 'requires password' do
    lambda { u = Factory.create(:user, :password => nil) }.should raise_error(ActiveRecord::RecordInvalid)
  end

  it 'requires email' do
    lambda { u = Factory.create(:user, :email => nil) }.should raise_error(ActiveRecord::RecordInvalid)
  end

  describe 'creating a duplicate user' do
    it 'should not allow two users with the same username' do
      @user = Factory.create(:user, :login => "duplicate")
      lambda { u = Factory.create(:user, :login => "duplicate") }.should raise_error(ActiveRecord::RecordInvalid)
    end

    it 'should not allow two users with the same username with different capitalization' do
      @user = Factory.create(:user, :login => "duplicate")
      lambda { u = Factory.create(:user, :login => "dUpLiCaTe") }.should raise_error(ActiveRecord::RecordInvalid)
    end
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

    # it 'should send welcome email after an unconfirmed user is created' do
    #   user = Factory.build(:user, :login => 'mylogin', :email => 'someone@limewire.com')
    #   user.unconfirm
    #   user.save
    #   ActionMailer::Base.deliveries.size.should == 1
    #   ActionMailer::Base.deliveries.first.to_addrs[0].to_s.should == user.email
    #   ActionMailer::Base.deliveries.first.body.should =~ /You've joined LimeCast, the web's open podcast directory and archive./
    #   ActionMailer::Base.deliveries.first.body.should =~ /Click to confirm your email/
    # end

    it 'should NOT send welcome email after a confirmed user is created' do
      Factory.create(:user, :login => 'mylogin', :confirmed => true, :email => 'someone@limewire.com')
      ActionMailer::Base.deliveries.size.should == 0
    end

    # it 'should send reconfirm email after confirmed email is changed' do
    #   user = Factory.create(:user, :email => 'someone@limewire.com')
    #   change_email = lambda { user.update_attribute(:email, 'my.new.email.address@limewire.com') }
    #   change_email.should change { ActionMailer::Base.deliveries.size }.by(1)
    #   user.reload.should_not be_confirmed
    #   ActionMailer::Base.deliveries.first.to_addrs[0].to_s.should == 'my.new.email.address@limewire.com'
    #   ActionMailer::Base.deliveries.first.subject.should == 'Confirm new email'
    #   ActionMailer::Base.deliveries.first.body.should =~ /You've changed your email address in LimeCast.\nClick to confirm your new email/
    # end

    # it 'should send reconfirm email after unconfirmed email is changed' do
    #   user = Factory.create(:unconfirmed_user, :email => 'someone@limewire.com')
    #   lambda {
    #     user.update_attribute(:email, 'my.new.email.addresssss@limewire.com')
    #   }.should change { ActionMailer::Base.deliveries.size }.by(1)
    #   user.should_not be_confirmed
    #   ActionMailer::Base.deliveries.last.to_addrs[0].to_s.should == 'my.new.email.addresssss@limewire.com'
    #   ActionMailer::Base.deliveries.last.subject.should == 'Confirm new email'
    #   ActionMailer::Base.deliveries.last.body.should =~ /You've changed your email address in LimeCast.\nClick to confirm your new email/
    # end

    after(:each) do
      reset_actionmailer
    end
  end
end

