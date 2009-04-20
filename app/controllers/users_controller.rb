class UsersController < ApplicationController
  # Protect these actions behind an admin login
  # before_filter :admin_required, :only => [:destroy]
  before_filter :find_user, :only => [:destroy]

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
    #require 'ruby-debug'; debugger
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

    @user = User.new(params[:user].keep_keys([:password, :email, :login]))
    @user.unconfirm
    @user.save if @user.valid?

    respond_to do |format|
      if @user.errors.empty? && @user.reload
        self.current_user = @user
        claim_records

        format.js { render :layout => false }
        format.html { redirect_back_or_default('/') }
      else
        format.js { render :layout => false }
        format.html { render :action => 'new' }
      end
    end
  end

  def activate
    self.current_user = params[:activation_code].blank? ? false : User.find_by_activation_code(params[:activation_code])
    if logged_in? && !current_user.confirmed?
      current_user.confirm
    end
    redirect_to user_url(:user_slug => current_user)
  end

  def destroy
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
    end

    if @user
      if @user.reset_password_sent_at and @user.reset_password_sent_at > 10.minutes.ago then
      else
        @user.generate_reset_password_code
        @user.save
      end
      redirect_to new_session_path
    else
      render
    end
  end

  # GET /claim/:code
  # POST /claim/:code
  # XXX
  def set_password
    @code = params[:code] or unauthorized
    @user = User.find_by_reset_password_code(@code) or unauthorized
    @user.confirm unless @user.confirmed?

    if request.post?
      if @user.update_attributes(params[:user])
        @user.reset_password_code = nil
        @user.reset_password_sent_at = nil
        @user.confirm

        self.current_user = @user
        redirect_to user_url(@user)
      else
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
    end

    if @user
      if @user.reset_password_sent_at and @user.reset_password_sent_at > 10.minutes.ago then
      else
        @user.generate_reset_password_code
        @user.save
        UserMailer.deliver_reset_password(@user)
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
      redirect_to(podcasts_url) and return false
    end

    @user.attributes = params[:user].keep_keys([:email, :login, :password])

    if @user.save
      redirect_to @user
    else
      render :action => 'show'
    end
  end

  def info
    raise Unauthenticated unless current_user && current_user.admin?
    if params[:user_slug].blank?
      @users = User.find(:all, :order => 'login ASC')
      render :template => 'users/info_all', :layout => 'info'
    else
      @user = User.find_by_login(params[:user_slug]) or raise ActiveRecord::RecordNotFound
      render :layout => 'info'
    end
  end

protected
  def find_user
    @user = User.find(params[:id])
  end
end
