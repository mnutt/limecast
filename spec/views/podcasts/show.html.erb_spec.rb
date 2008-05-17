require File.dirname(__FILE__) + '/../../spec_helper'

describe "/podcasts/show.html.erb" do
  include PodcastsHelper
  
  before(:each) do
    @podcast = mock_model(Podcast)
    @podcast.stub!(:title).and_return("MyString")
    @podcast.stub!(:site).and_return("MyString")
    @podcast.stub!(:feed).and_return("MyString")
    @podcast.stub!(:logo_file_name).and_return("MyString")
    @podcast.stub!(:logo_content_type).and_return("MyString")
    @podcast.stub!(:logo_file_size).and_return("MyString")

    assigns[:podcast] = @podcast
  end

  it "should render attributes in <p>" do
    render "/podcasts/show.html.erb"
    response.should have_text(/MyString/)
    response.should have_text(/MyString/)
    response.should have_text(/MyString/)
    response.should have_text(/MyString/)
    response.should have_text(/MyString/)
    response.should have_text(/MyString/)
  end
end

