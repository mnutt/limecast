# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  include AuthenticatedSystem

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'f5ddc48f3727a5fb383bccf339c7d49c'

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
end
