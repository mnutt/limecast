require 'open-uri'
require 'hpricot'

class GoogleSearchResult
  attr_accessor :html, :per_page

  def initialize(query, options = {})
    results = options[:per_page] || 100

    fetch!(URI.encode(query))
    @doc     = Hpricot(html)
    @results = (@doc/'body li')
    remove_extra_results!
    @links   = @results.map { |li| (li/'a.l')[0]['href'] if (li/'a.l')[0] }.reject(&:blank?)
  end
  
  def size
    @results.size
  end
  
  def [](int)
    @results[int]
  end
  
  def rank(host)
    return @rank if @rank

    link = @links.find { |url| URI.parse(url).host =~ /#{Regexp.escape(host)}/ }
    @rank = @links.index(link) ? @links.index(link) + 1 : nil  # convert from index to rank
  end
  
  protected
    def remove_extra_results!
      @results.reject! { |li| (li/'a')[0].inner_html =~ /(Video|Image) results for/ }
    end
  
    def fetch!(query)
      @html = open("http://www.google.com/search?hl=en&client=safari&rls=en-us&num=#{per_page}&q=#{query}&btnG=Search").read
    end
end