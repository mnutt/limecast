require File.dirname(__FILE__) + '/../spec_helper'

# Be sure to include AuthenticatedTestHelper in spec/spec_helper.rb instead.
# Then, you can remove it from this and the functional test.
include AuthenticatedTestHelper

describe UserMailer do
  before do
    @user = Factory.create(:user)
  end

  before(:each) do
    setup_actionmailer
  end

  it 'should send a reset password email' do
    lambda { UserMailer.deliver_reset_password(@user) }.should change { ActionMailer::Base.deliveries.size }.by(1)
    ActionMailer::Base.deliveries.first.to_addrs.map { |to| to.to_s }.should == [@user.email]
    ActionMailer::Base.deliveries.first.subject.should == 'Password reset link'
    ActionMailer::Base.deliveries.first.body.should =~ /LimeCast received a request to reset your password./
  end

  it 'should send activation email' do
    lambda { UserMailer.deliver_activation(@user) }.should change { ActionMailer::Base.deliveries.size }.by(1)
    ActionMailer::Base.deliveries.first.to_addrs.map { |to| to.to_s }.should == [@user.email]
    ActionMailer::Base.deliveries.first.subject.should == 'Your account has been activated!'
    ActionMailer::Base.deliveries.first.body.should =~ /your account has been activated./
  end

  it 'should send a reconfirm notification email' do
    @user.send(:make_pending)
    lambda { UserMailer.deliver_reconfirm_notification(@user) }.should change { ActionMailer::Base.deliveries.size }.by(1)
    ActionMailer::Base.deliveries.first.to_addrs.map { |to| to.to_s }.should == [@user.email]
    ActionMailer::Base.deliveries.first.subject.should == 'Confirm new email'
    ActionMailer::Base.deliveries.first.body.should =~ /You've changed your email address in LimeCast./
  end

  it 'should send a signup notification email' do
    @user.send(:make_pending)
    lambda { UserMailer.deliver_signup_notification(@user) }.should change { ActionMailer::Base.deliveries.size }.by(1)
    ActionMailer::Base.deliveries.first.to_addrs.map { |to| to.to_s }.should == [@user.email]
    ActionMailer::Base.deliveries.first.subject.should == 'Welcome to LimeCast!'
    ActionMailer::Base.deliveries.first.body.should =~ /You've joined LimeCast, the web's open podcast directory and archive./
  end

  after(:each) do
    reset_actionmailer
  end
end

