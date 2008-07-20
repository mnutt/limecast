require File.dirname(__FILE__) + '/../../../spec_helper'

describe "/admin/podcasts/show.html.erb" do
  before(:each) do
    @podcast = mock_model(Podcast)
    @podcast.stub!(:title).and_return("MyString")
    @podcast.stub!(:site).and_return("MyString")
    @podcast.stub!(:feed).and_return("MyString")
    @podcast.stub!(:created_at).and_return(Time.now)
    @podcast.stub!(:updated_at).and_return(Time.now)
    @podcast.stub!(:feed_etag).and_return("MyString")
    @podcast.stub!(:user_id).and_return("MyString")
    @podcast.stub!(:description).and_return("MyText")
    @podcast.stub!(:language).and_return("MyString")

    assigns[:podcast] = @podcast
  end

  it "should render attributes in <p>" do
    render "/admin/podcasts/show.html.erb"
    response.should have_text(/MyString/)
    response.should have_text(/MyString/)
    response.should have_text(/MyString/)
    response.should have_text(/MyString/)
    response.should have_text(/MyText/)
    response.should have_text(/MyString/)
  end
end

