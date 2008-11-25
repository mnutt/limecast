class AdminController < ApplicationController
  before_filter :require_admin

  def index
  end

  def icons
  end

  protected
  def require_admin
    return unauthenticated unless current_user
    return unauthorized unless current_user.admin?
  end
end
