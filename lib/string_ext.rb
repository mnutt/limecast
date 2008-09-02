class String
  def to_url
    self.
      sub(%r{^[^:]+://}, ""). # Removes protocol
      sub(%r{^www\.}, "").    # Removes www
      sub(%r{/$}, "")         # Removes trailing slash
  end
end

