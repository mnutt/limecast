# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
require 'thinking_sphinx' # HACK: fix weird TS require issues

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  include ExceptionNotifiable
  include AuthenticatedSystem

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'f5ddc48f3727a5fb383bccf339c7d49c'

  # Don't show passwords in logs
  filter_parameter_logging :password, :password_confirmation

  before_filter :read_tracker
  def read_tracker
    tracker_file = "#{RAILS_ROOT}/private/tracker.txt"
    @tracker ||= File.read(tracker_file).strip if File.exist?(tracker_file)
  end

  before_filter :read_ads
  def read_ads
    ad_file = "#{RAILS_ROOT}/private/ads.txt"
    @ads ||= File.read(ad_file) if File.exist?(ad_file)
  end

  protected
    def authenticate
      self.current_user = @user = User.authenticate(params[:user][:login], params[:user][:password])

      if logged_in?
        claim_all # deprecated, being replaced...
        claim_records # <-- with this
        set_cookies
        current_user.calculate_score!
        current_user.update_attribute(:logged_in_at, Time.now)
        return true
      else 
        return false
      end
    end

    def set_cookies
      current_user.remember_me unless current_user.remember_token?
      cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
    end

    def local_request?
      false
    end

    rescue_from ThinkingSphinx::ConnectionError,
                Riddle::ResponseError,                         :with => :sphinx_error
    rescue_from Forbidden,                                     :with => :redirect_with_forbidden
    rescue_from Unauthenticated,                               :with => :redirect_with_unauthenticated
    rescue_from ActionController::InvalidAuthenticityToken,    :with => :redirect_with_unauthenticated
    rescue_from ActiveRecord::RecordNotFound,
                ActionController::RoutingError,
                ActionController::UnknownAction,               :with => :render_404
    rescue_from ActionController::MethodNotAllowed,            :with => :render_405

    # Error handlers

    def tampered_cookie
      redirect_to_home "There was a problem with the cookie, probably due to site upgrades.  Please try again."
    end

    def sphinx_error
      render_exception(500, "Search Error")
    end

    def redirect_with_unauthenticated(exception)
      logger.info "Rescuing from: #{exception}"
      respond_to do |format|
        format.html { redirect_to_home "Sorry, you need to be logged in to access that page." }
        format.js { head(:unauthorized) }
      end
    end

    def redirect_with_forbidden(exception)
      logger.info "Rescuing from: #{exception}"
      respond_to do |format|
        format.html { redirect_to_home "Sorry, you are not allowed to access that page." }
        format.js { head(:forbidden) }
      end
    end

    def render_404
      render_exception(404, "Not Found")
    end

    def render_405
      render_exception(405, "Method Not Allowed")
    end

    def render_exception(status, title = "Server Error")
      @title = title
      @error = status

      respond_to do |format|
        format.html { render :template => "errors/#{status}", :status => status }
        format.xml  { render :xml => {:status => interpret_status(status)}.to_xml }
        format.js   { head(status) }
      end
    end

    def send_exception(e)
      # HACK: Fix our rescue action to work with Exception Notifier plugin
      deliverer = self.class.exception_data
      data = case deliverer
             when nil then {}
             when Symbol then send(deliverer)
             when Proc then deliverer.call(self)
             end

      ExceptionNotifier.deliver_exception_notification(e, self, request, data)
    end

    def redirect_to_home(message)
      flash[:notice] = message
      redirect_to "/"
    end

    def logout
      self.current_user.forget_me if logged_in?
      cookies.delete :auth_token
      reset_session
    end
    
    # Stores another [classname, id] in the session for the person to claim when they signin
    def remember_unclaimed_record(record)
      session[:unclaimed_records] ||= []
      session[:unclaimed_records] << [record.class.to_s, record.id]
    end
    
    # Claims the unclaimed records stored in the session
    def claim_records
      session[:unclaimed_records].each do |klass, record_id|
        record = klass.constantize.find(record_id)
        record.claim_by(current_user) if record
      end.clear if session[:unclaimed_records]
    end

    def claim_all
      if logged_in?
        claim_rating

        current_user.calculate_score!
      end
    end

    def claim_rating
      return if session[:rating].nil?

      session[:rating][:user_id] = current_user.id
      ReviewRating.create(session[:rating])

      session.delete(:rating)
    end


    # NOTE: on new remember_claimed_records method, try adding a claim(user.id) method to each model
    # so we can do extra stuff like this owner stuff!!!!
    def claim_feeds
      return if session[:feeds].nil?

      Feed.find_all_by_id(session[:feeds]).each do |feed|
        feed.update_attribute(:finder_id, @user.id) if feed.finder.nil?
        feed.podcast.update_attribute(:owner_id, @user.id) if feed.podcast && feed.podcast.owner.nil? and feed.podcast.owner_email == @user.email
      end

      session.delete(:feeds)
    end
end
