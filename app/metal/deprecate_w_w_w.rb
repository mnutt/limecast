# Allow the metal piece to run in isolation
require(File.dirname(__FILE__) + "/../../config/environment") unless defined?(Rails)

class DeprecateWWW
  def self.call(env)
    if env['HTTP_HOST'].slice!(/^www\./)
      RAILS_DEFAULT_LOGGER.info "DeprecateWWW: Redirecting to http://#{env['HTTP_HOST']}#{env['REQUEST_URI']}"
      [302, {'Location' => "http://#{env['HTTP_HOST']}#{env['REQUEST_URI']}"}, []]
    else
     # A 400 status (Not Found) passes the call on to the next piece in the stack,
     # which can be another metal piece, or your rails application.
     [404, {"Content-Type" => "text/html"}, ["Not Found!"]]
   end
  end
end
