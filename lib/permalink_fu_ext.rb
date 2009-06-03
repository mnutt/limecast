module PermalinkFu
  class << self
    def escape_and_preserve_case(str)
      s = ((translation_to && translation_from) ? Iconv.iconv(translation_to, translation_from, str) : str).to_s
      s.gsub!(/[^\w ]+/, '')  # all non-word chars to blank
      s.strip!                # ohh la la
      s.gsub!(/\ +/, '-')     # spaces to dashes, preferred separator char everywhere
      s
    end
  end
end