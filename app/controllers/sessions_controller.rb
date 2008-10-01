# This controller handles the login/logout function of the site.
class SessionsController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem

  # render new.rhtml
  def new
  end

  def create
    self.current_user = @user = User.authenticate(params[:user][:login], params[:user][:password])
    if logged_in?
      claim_podcasts
      if params[:remember_me] == "1"
        current_user.remember_me unless current_user.remember_token?
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      respond_to do |format|
        format.html do
          flash[:notice] = "Logged in successfully"
          redirect_back_or_default('/')
        end
        format.js
      end
    else
      respond_to do |format|
        format.html do
          flash.now[:notice] = "There was a problem logging in"
          render :action => 'new'
        end
        format.js
      end
    end
  end

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end

  protected

  def claim_podcasts
    return if session.data[:podcasts].nil?

    Podcast.find_all_by_id(session.data[:podcasts]).each do |podcast|
      podcast.user = @user if podcast.user.nil?
      podcast.owner = @user if podcast.owner.nil? and podcast.email == @user.email
      podcast.save
    end

    session.data.delete(:podcasts)
  end
end
