# This controller handles the login/logout function of the site.
class SessionsController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem

  # render new.rhtml
  def new
  end

  def create
    authenticate

    @unknown_user  = !User.find_by_login(params[:user][:login]) if params[:user][:login] !~ /@/
    @unknown_email = !User.find_by_email(params[:user][:login]) if params[:user][:login] =~ /@/
    respond_to do |format|
      format.js { render :layout => false }
      format.html { redirect_back_or_default('/') }
    end
  end

  def destroy
    logout
    redirect_back_or_default('/')
  end

  protected

  def authenticate
    self.current_user = @user = User.authenticate(params[:user][:login], params[:user][:password])

    if logged_in?
      claim_all
      set_cookies
      current_user.calculate_score!
      current_user.update_attribute(:logged_in_at, Time.now)
    end
  end

  def set_cookies
    current_user.remember_me unless current_user.remember_token?
    cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
  end
end
