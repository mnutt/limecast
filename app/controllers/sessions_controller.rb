# This controller handles the login/logout function of the site.
class SessionsController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem

  # for create(:js)
  include ERB::Util
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TagHelper
  include ApplicationHelper
  include SessionsHelper

  def new
  end

  def create
    authenticate

    @unknown_user  = !User.find_by_login(params[:user][:login]) if params[:user][:login] !~ /@/
    @unknown_email = !User.find_by_email(params[:user][:login]) if params[:user][:login] =~ /@/
    respond_to do |format|
      # Took this out of create.js.erb because rspec isn't seeing it (after upgrading to 2.3)
      format.html { redirect_back_or_default('/') }
      format.js do 
        msg = if logged_in?
          { :success => true, 
            :html => "Successful signin, #{link_to_profile(current_user)}." }
        else
          { :success => false,
            :html => "<p>#{create_session_error(params)}</p>" }
        end
        render :json => msg
      end
    end
  end

  def destroy
    logout
    redirect_back_or_default('/')
  end
end
