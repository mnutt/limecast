class UsersController < ApplicationController
  # Protect these actions behind an admin login
  # before_filter :admin_required, :only => [:suspend, :unsuspend, :destroy, :purge]
  before_filter :find_user, :only => [:suspend, :unsuspend, :destroy, :purge, :update]

  # render new.rhtml
  def new
  end

  def create
    cookies.delete :auth_token
    # protects against session fixation attacks, wreaks havoc with
    # request forgery protection.
    # uncomment at your own risk
    # reset_session
    @user = User.new(params[:user])
    @user.register! if @user.valid?
    if @user.errors.empty?
      claim_podcasts

      self.current_user = @user
      redirect_back_or_default('/')
      flash[:notice] = "Thanks for signing up!"
    else
      render :action => 'new'
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

  def show
    @user = User.find_by_login(params[:user])
  end

  def update
    @user == current_user || unauthorized

    respond_to do |format|
      format.js do
        if @user.update_attributes!(params[:user])
          render :text => @user.reload.attributes[params[:user].keys.first]
        else
          render :text => "There was a problem saving.  Please refresh the page."
        end
      end
    end
  end

protected
  def find_user
    @user = User.find(params[:id])
  end

  def claim_podcasts
    return if session.data[:podcasts].nil?

    Podcast.find_all_by_id(session.data[:podcasts]).each do |podcast|
      podcast.user = @user if podcast.user.nil?
      podcast.owner = @user if podcast.owner.nil? and podcast.email == @user.email
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

end
