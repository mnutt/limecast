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
    @ads ||= "" #File.read(ad_file) if File.exist?(ad_file)
  end

  protected
    def authenticate
      self.current_user = @user = User.authenticate(params[:user][:email], params[:user][:password])

      if logged_in?
        claim_records
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

    def render_500
      render_exception(500, "Site Issues")
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
      redirect_to "/"
    end

    def logout
      self.current_user.forget_me if logged_in?
      self.current_user = nil
      cookies.delete :auth_token
      reset_session
    end

    # Stores another 'ClassName' => [id] pair in the session for the person to claim when they signin
    def remember_unclaimed_record(record)
      if logged_in?
        record.claim_by(current_user)
      else
        session[:unclaimed_records] ||= {}
        (session[:unclaimed_records][record.class.to_s] ||= []) << record.id
      end
      record
    end

    # Claims the unclaimed records stored in the session
    def claim_records
      session[:unclaimed_records].each_pair do |klass, record_ids|
        record_ids.each do |record_id|
          if record = (klass.constantize.find(record_id) rescue nil)
            record.claim_by(current_user)
            @claimed_records = true
          end
        end
      end.clear if session[:unclaimed_records]
    end
    
    # A ivar to record if we've claimed any records in this request
    def claimed_records? 
      @claimed_records || false
    end
    helper_method :claimed_records?

    # Returns true if the non-logged-in user has the given class in their session's unclaimed_records.
    # If +func+ is passed in, this only returns true if the func is true for at least one of the records
    # of this class in the session[:unclaimed_records]
    def has_unclaimed_record?(klass, func=nil)
      if session[:unclaimed_records] && session[:unclaimed_records][klass.to_s] && records = klass.find(session[:unclaimed_records][klass.to_s].compact)
        return false if records.empty?
        return false if func && !records.any?(&func)
        return true
      else
        return false
      end
    end

    # Omit AJAX from CSFR protection; we can remove this overwritten method
    # when we upgrade to Rails 3.
    def verified_request?
      !protect_against_forgery?   ||
      request.method == :get      ||
      request.xhr?                ||
      !verifiable_request_format? ||
      form_authenticity_token == params[request_forgery_protection_token]
    end
end
