require File.dirname(__FILE__) + '/../../../spec_helper'

describe "/admin_episodes/show.html.erb" do
  include Admin::EpisodesHelper
  
  before(:each) do
    @episode = mock_model(Admin::Episode)
    @episode.stub!(:summary).and_return("MyText")
    @episode.stub!(:published_at).and_return(Time.now)
    @episode.stub!(:enclosure_url).and_return("MyString")
    @episode.stub!(:created_at).and_return(Time.now)
    @episode.stub!(:updated_at).and_return(Time.now)
    @episode.stub!(:guid).and_return("MyString")
    @episode.stub!(:enclosure_type).and_return("MyString")
    @episode.stub!(:duration).and_return("1")
    @episode.stub!(:title).and_return("MyString")

    assigns[:episode] = @episode
  end

  it "should render attributes in <p>" do
    render "/admin_episodes/show.html.erb"
    response.should have_text(/MyText/)
    response.should have_text(/MyString/)
    response.should have_text(/MyString/)
    response.should have_text(/MyString/)
    response.should have_text(/1/)
    response.should have_text(/MyString/)
  end
end

