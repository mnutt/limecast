require File.dirname(__FILE__) + '/../../../spec_helper'

describe "/admin/podcasts/index.html.erb" do
  before(:each) do
    podcast_98 = mock_model(Podcast)
    podcast_98.should_receive(:title).and_return("MyString")
    podcast_98.should_receive(:site).and_return("MyString")
    podcast_98.should_receive(:feed).and_return("MyString")
    podcast_98.should_receive(:created_at).and_return(Time.now)
    podcast_98.should_receive(:updated_at).and_return(Time.now)
    podcast_98.should_receive(:feed_etag).and_return("MyString")
    podcast_98.should_receive(:user_id).and_return("MyString")
    podcast_98.should_receive(:description).and_return("MyText")
    podcast_98.should_receive(:language).and_return("MyString")
    podcast_99 = mock_model(Podcast)
    podcast_99.should_receive(:title).and_return("MyString")
    podcast_99.should_receive(:site).and_return("MyString")
    podcast_99.should_receive(:feed).and_return("MyString")
    podcast_99.should_receive(:created_at).and_return(Time.now)
    podcast_99.should_receive(:updated_at).and_return(Time.now)
    podcast_99.should_receive(:feed_etag).and_return("MyString")
    podcast_99.should_receive(:user_id).and_return("MyString")
    podcast_99.should_receive(:description).and_return("MyText")
    podcast_99.should_receive(:language).and_return("MyString")

    assigns[:admin_podcasts] = [podcast_98, podcast_99]
  end

  it "should render list of admin_podcasts" do
    render "/admin/podcasts/index.html.erb"
    response.should have_tag("tr>td", "MyString", 2)
    response.should have_tag("tr>td", "MyString", 2)
    response.should have_tag("tr>td", "MyString", 2)
    response.should have_tag("tr>td", "MyString", 2)
    response.should have_tag("tr>td", "MyText", 2)
    response.should have_tag("tr>td", "MyString", 2)
  end
end

