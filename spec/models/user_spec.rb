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
        Factory.create(:feed, :finder => @user)
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
end

