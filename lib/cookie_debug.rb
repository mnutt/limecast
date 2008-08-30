class DebugTools
  class << self
    def show_session(cookie)
      Marshal.load(Base64.decode64(CGI.unescape(cookie.split("\n").join).split('--').first))
    end
  end
end
