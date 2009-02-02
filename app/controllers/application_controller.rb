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
    @tracker ||= File.read(tracker_file) if File.exist?(tracker_file)
  end

  before_filter :read_ads
  def read_ads
    ad_file = "#{RAILS_ROOT}/private/ads.txt"
    @ads ||= File.read(ad_file) if File.exist?(ad_file)
  end

  protected
    def local_request?
      false
    end

    # FIXME what happened to tamperedwithcookie?
    # rescue_from ActionController::Session::CookieStore::TamperedWithCookie, :with => :tampered_cookie
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

    def redirect_with_unauthenticated
      redirect_to_home "Sorry, you need to be logged in to access that page."
    end

    def redirect_with_forbidden
      redirect_to_home "Sorry, you are not allowed to access that page."
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

    def claim_all
      if logged_in?
        claim_feeds
        claim_review
        claim_favorites
        claim_rating

        current_user.calculate_score!
      end
    end

    def claim_favorites
      return if session[:favorite].nil?

      if Favorite.count(:conditions => {:user_id => current_user.id, :podcast_id => session[:favorite]}) == 0
        c = Favorite.new(:podcast_id => session[:favorite])
        c.user = current_user
        c.save
      end

      session.data.delete(:favorite)
    end

    def claim_rating
      return if session[:rating].nil?

      session[:rating][:user_id] = current_user.id
      ReviewRating.create(session[:rating])

      session.data.delete(:rating)
    end

    def claim_review
      return if session[:review].nil?

      if Review.count(:conditions => {:episode_id => session[:review][:episode_id], :user_id => current_user.id}) == 0
        c = Review.new(session[:review])
        c.reviewer = current_user
        c.save
      end

      session.data.delete(:review)
    end

    def claim_feeds
      return if session.data[:feeds].nil?

      Feed.find_all_by_id(session.data[:feeds]).each do |feed|
        feed.update_attribute(:finder_id, @user.id) if feed.finder.nil?
        feed.podcast.update_attribute(:owner_id, @user.id) if feed.podcast && feed.podcast.owner.nil? and feed.podcast.owner_email == @user.email
      end

      session.data.delete(:feeds)
    end
end
