require 'rexml/formatters/default'
require 'rexml/formatters/pretty'
require 'rexml/document'

class PrettyPrinter
  def self.indent_xml(doc)
    zdoc = doc
    doc = REXML::Document.new(doc.to_s.strip) rescue nil
    unless doc  #  Hpricot didn't well-formify the HTML!
      return zdoc.to_s  #  note: not indented, but good enough for error messages
    end
    
    formatter = REXML::Formatters::Pretty.new
    formatter.compact = true
    out = String.new
    formatter.write(doc, out)
    return out
  end
end

# Fix rexml's pretty print -- TODO: brittle
class REXML::Formatters::Pretty
  def wrap(string, width)
    # Recursively wrap string at width.
    return string if string.length <= width
    place = string.rindex(' ', width) # Position in string with last ' ' before cutoff
    return string if place.nil? # there aren't any ' 's before cutoff, nothing to split on.
    return string[0,place] + "\n" + wrap(string[place+1..-1], width)
  end
end
