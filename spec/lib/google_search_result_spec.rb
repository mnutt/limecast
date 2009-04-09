require File.dirname(__FILE__) + '/../spec_helper'

describe GoogleSearchResult, "being parsed" do

  before do
    @results = GoogleSearchResult.new("1up show")
    # @qf = QueuedFeed.create(:url => "http://google.com/rss.xml")
    # mod_and_run_feed_processor(@qf, FetchExample)
    # @feed = @qf.feed
  end

  it "should be a GoogleSearchResult" do
    @results.should be_a(GoogleSearchResult)
  end

  it "should have 50 results" do
    @results.size.should be(50)
  end
  
  it "should find limecast.com at 25th" do
    @results.rank('limecast.com').should be(25)
  end

end

