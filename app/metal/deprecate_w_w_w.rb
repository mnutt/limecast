# Allow the metal piece to run in isolation
require(File.dirname(__FILE__) + "/../../config/environment") unless defined?(Rails)

class DeprecateWWW
  def self.call(env)
    if env['HTTP_HOST'].slice!(/^www\./)
      location = "#{env['rack.url_scheme']}://#{env['HTTP_HOST']}#{env['REQUEST_URI']}"
      RAILS_DEFAULT_LOGGER.info "DeprecateWWW: Redirecting to #{location}"
      [302, {'Location' => location}, []]
    else
     # A 400 status (Not Found) passes the call on to the next piece in the stack,
     # which can be another metal piece, or your rails application.
     [404, {"Content-Type" => "text/html"}, ["Not Found!"]]
   end
  end
end
