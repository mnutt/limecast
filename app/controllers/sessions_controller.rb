# This controller handles the login/logout function of the site.
class SessionsController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem

  def new
  end

  def create
    authenticate

    @unknown_user  = !User.find_by_login(params[:user][:email]) if params[:user][:email] !~ /@/
    @unknown_email = !User.find_by_email(params[:user][:email]) if params[:user][:email] =~ /@/
    respond_to do |format|
      format.html { redirect_back_or_default('/') }
      format.js { render :layout => false }
    end
  end

  def destroy
    logout
    redirect_back_or_default('/')
  end
end
