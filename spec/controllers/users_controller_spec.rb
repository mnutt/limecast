require File.dirname(__FILE__) + '/../spec_helper'

# Be sure to include AuthenticatedTestHelper in spec/spec_helper.rb instead
# Then, you can remove it from this and the units test.
include AuthenticatedTestHelper

describe UsersController do

  it 'allows signup' do
    lambda do
      create_user
      response.should be_redirect
    end.should change(User, :count).by(1)
  end

  it 'requires login on signup' do
    lambda do
      create_user(:login => nil)
      assigns[:user].errors.on(:login).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end

  it 'requires password on signup' do
    lambda do
      create_user(:password => nil)
      assigns[:user].errors.on(:password).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end

  it 'requires email on signup' do
    lambda do
      create_user(:email => nil)
      assigns[:user].errors.on(:email).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end

  def create_user(options = {})
    post :create, :user => { :login => 'quire', :email => 'quire@example.com',
      :password => 'quire' }.merge(options)
  end
end

describe UsersController, "handling POST /users" do
  describe "when the email is bad" do
    before do
      post :create, :user => {:login => 'quire', :password => 'blah'}, :format => 'js'
    end

    it 'should not succeed' do
      decode(response)["success"].should be_false
    end

    it 'should report that the email address should be entered' do
      decode(response)["html"].should =~ /type your email/
    end
  end

  describe "when the password is bad" do
    before do
      post :create, :user => {:login => 'quire'}, :format => 'js'
    end

    it 'should not succeed' do
      decode(response)["success"].should be_false
    end

    it 'should report that the password should be entered' do
      decode(response)["html"].should =~ /choose a password/
    end
  end

  describe "when the user name is bad" do
    before do
      post :create, :user => {:email => "quire@example.com", :password => 'goodpass'}, :format => 'js'
    end

    it 'should not succeed' do
      decode(response)["success"].should be_false
    end

    it 'should report that the user name should be entered' do
      decode(response)["html"].should =~ /Choose your new user name/
    end
  end

  describe "when the email is known, and the password is right" do
    before do
      @user = Factory.create(:user, :login => 'quire', :password => 'quire', :email => 'quire@example.com')
      post :create, :user => {:login => 'quire', :password => 'quire'}, :format => 'js'
    end

    it 'should succeed' do
      decode(response)["success"].should be_true
    end

    it 'should return the user link' do
      decode(response)["html"].should =~ /quire \(0\)/
    end
  end

  describe "when the email is known, but the password is wrong" do
    before do
      @user = Factory.create(:user, :login => 'quire', :email => 'quire@example.com')

      post :create, :user => {:login => 'quire',
                              :email => 'quire@example.com',
                              :password => 'bad'}, :format => 'js'
    end

    it 'should not succeed' do
      decode(response)["success"].should be_false
    end

    it 'should report that the email matches, but password is wrong' do
      decode(response)["html"].should =~ /Sorry/
    end
  end

  describe "when the user name has already been taken" do
    before do
      @user = Factory.create(:user)
      post :create, :user => {:login => @user.login, :password => "goodpass", :email => "quire@example.com"}, :format => 'js'
    end

    it 'should not succeed' do
      decode(response)["success"].should be_false
    end

    it 'should report that the username has already been taken' do
      response.body.should =~ /Sorry, this user name is taken/
    end
  end

  def decode(response)
    ActiveSupport::JSON.decode(response.body.gsub("'", ""))
  end

  describe "when the new user can be created" do
    before do
      post :create, :user => {:login => "quire", :password => "goodpass", :email => "quire@example.com"}, :format => 'js'
    end

    it 'should succeed' do
      decode(response)["success"].should be_true
    end

    it 'should return the link_to_user' do
      decode(response)["html"].should =~ /quire \(0\)/
    end
  end
end

describe UsersController, "handling POST /user/:user" do
  describe "when user is the current user" do

    before(:each) do
      @user = Factory.create(:user)
      login(@user)

      post :update, :user => @user.login, :user_attr => {:email => "newemail@example.com"}
    end

    it "should find the user requested" do
      assigns(:user).id.should == @user.id
    end

    it "should update the user" do
      assigns(:user).reload.email.should == "newemail@example.com"
    end

    it "should set the user to pending" do
      assigns(:user).state.should == "pending"
      assigns(:user).activation_code.should_not be_nil
    end

    it "should redirect to the user page" do
      response.should redirect_to(user_url(:user => @user))
    end
  end

  describe "when user is not authorized" do

    before(:each) do
      @user = Factory.create(:user)
      User.should_receive(:find_by_login).and_return(@user)
      @user.should_receive(:==).and_return(false)
      login(@user)
    end

    it "should be forbidden" do
      lambda {
        post :update, :user => @user.login, :user_attr => {:email => "newemail@example.com"}
      }.should raise_error(Forbidden)
    end
  end

  describe "when user enters malicious params" do

    before(:each) do
      @user = Factory.create(:user)
      login(@user)

      post :update, :user => @user.login, :user_attr => {:score => "584"}
    end

    it "should redirect to the podcasts list" do
      assigns(:user).score.should == 0
    end
  end
end

describe UsersController, "handling GET /user" do
  before(:each) do
    @user = Factory.create(:user)
    get :index
  end

  it 'should have a list of users' do
    assigns(:users).should == [@user]
  end
end
