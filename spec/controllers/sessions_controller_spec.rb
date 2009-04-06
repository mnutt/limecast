require File.dirname(__FILE__) + '/../spec_helper'

# Be sure to include AuthenticatedTestHelper in spec/spec_helper.rb instead
# Then, you can remove it from this and the units test.
include AuthenticatedTestHelper

describe SessionsController do
  integrate_views

  before do
    @user = Factory.create(:user, :logged_in_at => 2.days.ago)

    request.env["HTTP_REFERER"] = "/"
  end

  def decode(response)
    ActiveSupport::JSON.decode(response.body.gsub("'", ""))
  end


  def do_post
    post :create, :user => { :login => @user.login, :password => @user.password }
  end

  it 'login and redirect' do
    post :create, :user => { :login => @user.login, :password => @user.password }
    session[:user_id].should_not be_nil
    @user.reload.logged_in_at.to_i.should == Time.now.to_i
    response.should be_redirect
  end
  
  it 'login and claim reviews' do
    @review = Factory.create(:review, :reviewer => nil)
    @podcast = @review.episode.podcast
    session[:unclaimed_records] = {'Review' => [@review.id]}

    lambda { do_post }.should change { @podcast.reload.reviews.count }.by(1)
    @podcast.reviews.should include(@review)
    session[:unclaimed_records].should be_empty
  end

  it 'fails login and does not redirect' do
    post :create, :user => { :login => @user.login, :password => "xxxx" }, :format => 'js'
    session[:user_id].should be_nil
    response.should be_success
    decode(response)['html'].should =~ /User and password don\t match./
  end

  it 'fails login and notices when new email has been given' do
    post :create, :user => { :login => 'newemail@example.com', :password => 'xxxx' }, :format => 'js'
    session[:user_id].should be_nil
    response.should be_success
    response.body.should =~ /This email is new to us./
  end

  it 'logs out' do
    post :create, :user => { :login => @user.login, :password => @user.password }
    get :destroy
    session[:user_id].should be_nil
    response.should be_redirect
  end

  it 'remembers me' do
    post :create, :user => { :login => @user.login, :password => @user.password }
    response.cookies["auth_token"].should_not be_nil
  end

  it 'deletes token on logout' do
    post :create, :user => { :login => @user.login, :password => @user.password }
    get :destroy
    response.cookies["auth_token"].should == nil
  end

  it 'logs in with cookie' do
    @user.remember_me
    request.cookies["auth_token"] = cookie_for(@user)
    get :new
    controller.send(:logged_in?).should be_true
  end

  it 'fails expired cookie login' do
    @user.remember_me
    @user.update_attribute :remember_token_expires_at, 5.minutes.ago
    request.cookies["auth_token"] = cookie_for(@user)
    get :new
    controller.send(:logged_in?).should_not be_true
  end

  it 'fails cookie login' do
    @user.remember_me
    request.cookies["auth_token"] = auth_token('invalid_auth_token')
    get :new
    controller.send(:logged_in?).should_not be_true
  end

  def auth_token(token)
    CGI::Cookie.new('name' => 'auth_token', 'value' => token)
  end

  def cookie_for(user)
    auth_token user.remember_token
  end
end
