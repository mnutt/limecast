require File.dirname(__FILE__) + '/../spec_helper'

GoogleSearchResult.class_eval <<-FAKE
  protected
  def fetch!(query)
    @html = open("spec/data/google_50_results_1upshow.html").read
  end
FAKE

describe GoogleSearchResult, "being parsed" do

  before do
    @results = GoogleSearchResult.new("1up show")
  end

  it "should be a GoogleSearchResult" do
    @results.should be_a(GoogleSearchResult)
  end

  it "should have 50 results" do
    @results.size.should be(50)
  end
  
  it "should find 'limecast.com' at 28th" do
    @results.rank('limecast.com').should be(28)
  end

  it "should find 'liiiiiiiiiiiiiiimecast.com' nowhere and return nil" do
    @results.rank('liiiiiiiiiiiiiiimecast.com').should be_nil
  end

end

