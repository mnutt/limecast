require File.dirname(__FILE__) + '/../spec_helper'

# Be sure to include AuthenticatedTestHelper in spec/spec_helper.rb instead
# Then, you can remove it from this and the units test.
include AuthenticatedTestHelper

describe UsersController do
  integrate_views

  it 'allows signup' do
    lambda do
      create_user(:format => 'html')
      response.should be_redirect
    end.should change(User, :count).by(1)
  end

  it 'signs in user after signup' do
    create_user(:format => 'html', :debug => true)
    session[:user_id].should be(User.last.id)
  end

  it 'requires login on signup' do
    lambda do
      create_user(:user => {:login => nil}, :format => 'js')
      assigns[:user].errors.on(:login).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end

  it 'requires password on signup' do
    lambda do
      create_user(:user => {:password => nil}, :format => 'js')
      assigns[:user].errors.on(:password).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end

  it 'requires email on signup' do
    lambda do
      create_user(:user => {:email => nil}, :format => 'js')
      assigns[:user].errors.on(:email).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end

  def create_user(options = {})
    post :create, {:user => {:login => 'quire', :email => 'quire@example.com', :password => 'quire'}}.merge(options)
  end
end

describe UsersController, "handling POST /users" do
  integrate_views

  describe "when the email is bad" do
    before do
      post :create, {:user => {:login => 'quire', :password => 'blah'}, :format => 'js'}
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
      decode(response)["html"].should =~ /Successful signin\,.*quire/
    end
  end

  describe "when the email is known, but the password is wrong" do
    before do
      @user = Factory.create(:user, :login => 'quire', :email => 'quire@example.com')
      post :create, :user => {:login => 'quire',
                              :email => 'quire@example.com',
                              :password => 'bad'} , :format => 'js'
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
      decode(response)["html"].should =~ /Successful signup\,.*quire/
    end
  end
end

describe UsersController, "handling PUT /user/:user" do
  integrate_views

  describe "when user is the current user" do

    before(:each) do
      @user = Factory.create(:user)
      login(@user)

      put :update, :user_slug => @user.login, :user => {:email => "newemail@example.com"}
    end

    it "should find the user requested" do
      assigns(:user).id.should == @user.id
    end

    it "should update the user" do
      assigns(:user).reload.email.should == "newemail@example.com"
    end

    it "should set the user to pending" do
      assigns(:user).should be_unconfirmed
      assigns(:user).activation_code.should_not be_nil
    end

    it "should redirect to the user page" do
      response.should redirect_to(user_url(:user_slug => @user))
    end
  end

  describe "when user is not authorized" do

    before(:each) do
      @user = Factory.create(:user)
      User.should_receive(:find_by_login).and_return(@user)
      @user.should_receive(:==).and_return(false)
      login(@user)
    end

    it "should raise Forbidden and be redirected to home" do
#      lambda {
        post :update, :user_slug => @user.login, :user => {:email => "newemail@example.com"}
        response.should redirect_to('/')
#      }.should raise_error(Forbidden)
    end
  end

  describe "when user enters malicious params" do

    before(:each) do
      @user = Factory.create(:user)
      login(@user)

      post :update, :user_slug => @user.login, :user => {:score => "584"}
    end

    it "should redirect to the podcasts list" do
      assigns(:user).score.should == 0
    end
  end
end

describe UsersController, "handling GET /user" do
  integrate_views

  before(:each) do
    @user = Factory.create(:user)
    get :index
  end

  it 'should have a list of users' do
    assigns(:users).should == [@user]
  end
end

describe UsersController, "handling GET /claim" do
  before(:each) do
    get :claim
  end

  it 'should succeed' do
    response.should be_success
  end

  it 'should render the /claim template' do
    response.should render_template('users/claim')
  end
end

describe UsersController, "handling POST /claim" do
  integrate_views

  before(:each) do
    @user = Factory.create(:passive_user)
  end

  def do_post(email)
    post :claim, :email => email
  end

  it 'should succeed if passive email is found' do
    do_post(@user.email)
    response.should redirect_to(new_session_path)
  end

  it 'should fail if passive email is not found' do
    do_post('jabberwocky@me.com')
    response.should render_template('claim')
  end

  it 'should fail if passive email is found but claimed twice in 10 minutes' do
    do_post(@user.email) and do_post(@user.email)
  end

  it 'should send an email if passive email is found' do
    lambda { do_post(@user.email) }.should change { ActionMailer::Base.deliveries.size }.by(1)
    ActionMailer::Base.deliveries.last.subject.should == "Claim your podcasts on LimeCast"
  end

  it 'should set user\'s reset_password_code if passive email is found' do
    lambda { do_post(@user.email) }.should change { @user.reload.reset_password_code }
    @user.reload.reset_password_sent_at.change(:sec => 0).should == Time.now.change(:sec => 0)
  end

  it "should not send email if passive email is not found" do
    lambda { do_post('jabberwocky@me.com') }.should_not change { ActionMailer::Base.deliveries.size }
    @user.reload.reset_password_sent_at.should be_nil
  end
end

describe UsersController, "handling GET /claim/:code" do
  integrate_views

  before(:each) do
    @user = Factory.create(:passive_user)
    @user.generate_reset_password_code
    @user.save
  end

  def do_get(code)
    get :set_password, :code => code
  end

  it 'should not succeed with incorrect code' do
    do_get('jabberwocky')
    response.should be_redirect
  end

  it 'should succeed' do
    do_get(@user.reset_password_code)
    response.should be_success
  end
end

describe UsersController, "handling POST /claim/:code" do
  integrate_views

  before(:each) do
    @user = Factory.create(:passive_user)
    @user.generate_reset_password_code
    @user.save
  end

  def do_post(code)
    post :set_password, :code => code, :user => {:password => '1234abcd'}
  end

  it 'should not succeed with incorrect code' do
    lambda { do_post('jabberwocky') }.should_not change { @user.crypted_password }
    response.should be_redirect
  end

  it 'should succceed with correct code' do
    do_post(@user.reset_password_code)
    response.should redirect_to(user_url(@user))
  end

  it 'should update the user\'s email' do
    lambda { do_post(@user.reset_password_code) }.should change { @user.reload.crypted_password }
  end


end
