# This controller handles the login/logout function of the site.
class SessionsController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem

  # render new.rhtml
  def new
  end

  def create
    authenticate
    if logged_in?
      current_user.calculate_score!
      current_user.update_attribute(:logged_in_at, Time.now)
    end

    respond_to do |format|
      format.html do
        if logged_in?
          flash[:notice] = "Successful sign in"
          redirect_to :back
        else
          flash.now[:notice] = "There was a problem logging in"
          render :action => 'new'
        end
      end
      format.js do
        @unknown_user = !User.find_by_login(params[:user][:login]) if params[:user][:login] !~ /@/
        @unknown_email = !User.find_by_email(params[:user][:login]) if params[:user][:login] =~ /@/
        render :layout => false
      end
    end
  end

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    redirect_back_or_default('/')
  end

  protected

  def authenticate
    self.current_user = @user = User.authenticate(params[:user][:login], params[:user][:password])

    if logged_in?
      claim_all
      set_cookies
    end
  end

  def set_cookies
    current_user.remember_me unless current_user.remember_token?
    cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
  end
end
