class String
  def to_url
    url = self.
      sub(%r{^[^:]+://}, "").     # Removes protocol
      sub(%r{^www\.}, "").        # Removes www
      sub(%r{\?.*$}, "").         # Removes trailing parameters
      sub(%r{index\.html$}, "").  # Removes trailing index.html
      sub(%r{/$}, "")             # Removes trailing slash

    parts = url.split('/')
    parts.first.downcase! if parts.first
    parts.join('/')
  end
end

