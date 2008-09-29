require File.dirname(__FILE__) + '/../spec_helper'

# Be sure to include AuthenticatedTestHelper in spec/spec_helper.rb instead
# Then, you can remove it from this and the units test.
include AuthenticatedTestHelper

describe UsersController do
  fixtures :users

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
  
  it 'requires password confirmation on signup' do
    lambda do
      create_user(:password_confirmation => nil)
      assigns[:user].errors.on(:password_confirmation).should_not be_nil
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
      :password => 'quire', :password_confirmation => 'quire' }.merge(options)
  end
end

describe UsersController, "handling POST /user/:user" do
  describe "when user is the podcast owner" do

    before(:each) do
      @user = Factory.create(:user)
      login(@user)
      
      post :update, :user => @user.login, :user_attr => {:email => "newemail@example.com"}
    end
    
    it "should find the user requested" do
      assigns(:user).id.should == @user.id
    end
    
    it "should update the found podcast" do
      assigns(:user).reload.email.should == "newemail@example.com"
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
