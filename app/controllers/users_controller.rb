class UsersController < ApplicationController
  # Protect these actions behind an admin login
  # before_filter :admin_required, :only => [:suspend, :unsuspend, :destroy, :purge]
  before_filter :find_user, :only => [:suspend, :unsuspend, :destroy, :purge]

  # render new.html.erb
  def new
  end

  def create
    cookies.delete :auth_token
    # protects against session fixation attacks, wreaks havoc with
    # request forgery protection.
    # uncomment at your own risk
    # reset_session
    if self.current_user = @user = User.authenticate(params[:user][:email], params[:user][:password])
      return
    end

    @user = User.new(params[:user].keep_keys([:email, :password, :password_confirmation, :login]))
    @user.state = 'passive'
    @user.register! if @user.valid?
    if @user.errors.empty?
      claim_podcasts

      self.current_user = @user
      respond_to do |format|
        format.html do
          redirect_back_or_default('/')
          flash[:notice] = "Thanks for signing up!"
        end
        format.js
      end
    else
      respond_to do |format|
        format.html { render :action => 'new' }
        format.js
      end
    end
  end

  def activate
    self.current_user = params[:activation_code].blank? ? false : User.find_by_activation_code(params[:activation_code])
    if logged_in? && !current_user.active?
      current_user.activate!
      flash[:notice] = "Signup complete!"
    end
    redirect_back_or_default('/')
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


  def reset_password
    @code = params[:code] or unauthorized
    @user = User.find_by_reset_password_code(@code) or unauthorized

    if request.post?
      if @user.update_attributes(params[:user])
        @user.reset_password_code = nil
        @user.reset_password_sent_at = nil
        @user.save

        self.current_user = @user
        flash[:notice] = 'Password updated successfully.'
        redirect_to user_url(@user)
      else
        flash[:notice] = 'The passwords do not match.'
      end
    end
  end

  def send_password
    @user = User.find_by_email(params[:email]) unless params[:email].blank?

    if @user
      if @user.reset_password_sent_at and @user.reset_password_sent_at > 10.minutes.ago then
        flash[:notice] = 'A reset password message was sent less than 10 minutes ago.  Please check your Inbox.'
      else
        @user.generate_reset_password_code
        @user.save
        UserMailer.deliver_reset_password(@user, request.host_with_port)

        flash[:notice] = [ "Password reset email sent", "Please check your Inbox for a message from LimeWire and click the provided link to reset your password." ]
      end
      redirect_to new_session_path
    else
      flash[:notice] = 'Sorry, could not find a user with that email.'
      redirect_to forgot_password_path
    end
  end

  def show
    @user = User.find_by_login(params[:user])
  end

  def update
    @user = User.find_by_login(params[:user])
    @user == current_user || unauthorized

    if @user.update_attributes!(params[:user_attr].keep_keys([:email]))
      reconfirm_email(@user)

      flash[:notice] = "Your account settings were successfully saved.  You will have to re-confirm your email if you changed it."
    else
      flash[:notice] = "There was a problem saving your settings."
    end

    redirect_to user_url(:user => @user)
  end

protected
  def find_user
    @user = User.find(params[:id])
  end

  def claim_podcasts
    return if session.data[:podcasts].nil?

    Podcast.find_all_by_id(session.data[:podcasts]).each do |podcast|
      podcast.user = @user if podcast.user.nil?
      podcast.owner = @user if podcast.owner.nil? and podcast.owner_email == @user.email
      podcast.save
    end

    session.data.delete(:podcasts)
  end

  def claim_comments
    return if session.data[:comments].nil?

    Comment.find_all_by_id(session.data[:comments]).each do |comment|
      comment.user = @user if comment.user.nil?
      comment.save
    end

    session.data.delete(:comments)
  end

  def reconfirm_email(user)
    user.change_email!
    UserMailer.deliver_signup_notification(user)
  end

end
