class UsersController < ApplicationController
  # for create(:js)
  #include ActionController::UrlWriter  
  # include ActionView::Helpers::UrlHelper
  # include ActionView::Helpers::TagHelper
  # include UsersHelper
  # include ApplicationHelper

  # Protect these actions behind an admin login
  # before_filter :admin_required, :only => [:suspend, :unsuspend, :destroy, :purge]
  before_filter :find_user, :only => [:suspend, :unsuspend, :destroy, :purge]

  def new
  end

  def index
    @users = User.all(:order => :login)
  end

  def favoriters
    @podcast = Podcast.find_by_slug(params[:podcast_slug])

    @users = @podcast.favoriters
  end

  def create
    cookies.delete :auth_token
    # protects against session fixation attacks, wreaks havoc with request forgery protection. uncomment at your own risk
    # reset_session

    if authenticate
      respond_to { |format|
        format.html { redirect_back_or_default('/') }
        format.js { render 'sessions/create' }
      }
      return
    end

    @user = User.new(params[:user].keep_keys([:email, :password, :login]))
    @user.state = 'pending'
    @user.register! if @user.valid?

    respond_to do |format|
      if @user.errors.empty?
        self.current_user = @user
        claim_all

        format.js { render 'users/create.js.erb' }# :json => { :success => true, :html => "Successful signup, #{link_to_profile(current_user)}." } }
        format.html { redirect_back_or_default('/') }
      else
        format.js { render 'users/create.js.erb', :layout => false }#:json => { :success => false,  :html => "<p>#{create_user_error(@user)}</p>" } }
        format.html { render :action => 'new' }
      end
    end
  end

  def activate
    self.current_user = params[:activation_code].blank? ? false : User.find_by_activation_code(params[:activation_code])
    if logged_in? && !current_user.active?
      current_user.activate!
      flash[:notice] = "Your email is confirmed. Thanks again for joining LimeCast!"
    end
    redirect_to user_url(:user_slug => current_user)
  end

  def suspend
    @user.suspend!
    redirect_to users_path
  end

  def unsuspend
    @user.unsuspend!
    redirect_to users_path
  end

  def destroy
    @user.delete!
    redirect_to users_path
  end

  def purge
    @user.destroy
    redirect_to users_path
  end

  def forgot_password
    render
  end

  # GET /claim
  # POST /claim?email=...
  def claim
    unless params[:email].blank?
      @user = User.passive.find_by_email(params[:email])
      flash[:notice] = "We could not find that email."
    end

    if @user
      if @user.reset_password_sent_at and @user.reset_password_sent_at > 10.minutes.ago then
        flash[:notice] = "We have already sent you a note. Please check your email."
      else
        @user.generate_reset_password_code
        @user.save
        UserMailer.deliver_claim_account(@user)
        flash[:notice] = "Got it. Check your email for a link to set your password."
      end
      redirect_to new_session_path
    else
      render
    end
  end

  # GET /claim/:code
  # POST /claim/:code
  def set_password
    @code = params[:code] or unauthorized
    @user = User.find_by_reset_password_code(@code) or unauthorized
    @user.activate! unless @user.active?

    if request.post?
      if @user.update_attributes(params[:user])
        @user.reset_password_code = nil
        @user.reset_password_sent_at = nil
        @user.activate!

        self.current_user = @user
        flash[:notice] = nil
        redirect_to user_url(@user)
      else
        flash[:notice] = @user.errors.full_messages.to_sentence
        render
      end
    end
  end

  def reset_password
    @code = params[:code] or unauthorized
    @user = User.find_by_reset_password_code(@code) or unauthorized

    if request.post?
      if @user.update_attributes(params[:user])
        @user.reset_password_code = nil
        @user.reset_password_sent_at = nil
        @user.save

        self.current_user = @user
        redirect_to user_url(@user)
      end
    end
  end

  def send_password
    unless params[:email].blank?
      @user = User.find_by_email(params[:email]) || User.find_by_login(params[:email])
      flash[:notice] = "We could not find that email."
    end

    if @user
      if @user.reset_password_sent_at and @user.reset_password_sent_at > 10.minutes.ago then
        flash[:notice] = "We have already sent you a note. Please check your email."
      else
        @user.generate_reset_password_code
        @user.save
        UserMailer.deliver_reset_password(@user)
        flash[:notice] = "Got it. Check your email for a link to reset your password."
      end
      redirect_to new_session_path
    else
      render :action => 'forgot_password'
    end
  end

  def show
    @user = User.find_by_login(params[:user_slug]) || User.find_by_login(params[:id])
    raise ActiveRecord::RecordNotFound if @user.nil?
  end

  def update
    @user = User.find_by_login(params[:user_slug])
    @user == current_user || unauthorized

    # The "_delete" attr is taken from Nested Association Attributes, but AR doesn't support
    # it on a regular model, so we're going to use the same convention when deleting the Podcast.
    if params[:user] && params[:user][:_delete] == '1'
      @user.destroy
      logout if @user == current_user
      flash[:notice] = "#{@user.login} has been removed."
      redirect_to(podcasts_url) and return false
    end

    @user.attributes = params[:user].keep_keys([:email, :login, :password])

    if @user.save
      flash[:notice] = 'User was successfully updated.'
      flash[:notice] << " #{@user.messages.join(' ')}"

      redirect_to @user
    else
      flash[:notice] = @user.errors.full_messages.join('. ')
      render :action => 'show'
    end
  end

  def info
    raise Unauthenticated unless current_user && current_user.admin?
    @user = User.find_by_login(params[:user_slug])
    render :layout => 'info'
  end

protected
  def find_user
    @user = User.find(params[:id])
  end
end
