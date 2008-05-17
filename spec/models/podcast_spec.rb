require File.dirname(__FILE__) + '/../spec_helper'

describe Podcast do
  before(:each) do
    @podcast = Podcast.new
  end

  it "should be valid" do
    @podcast.should be_valid
  end
end
