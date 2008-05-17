require File.dirname(__FILE__) + '/../../spec_helper'

describe "/episodes/show.html.erb" do
  include EpisodesHelper
  
  before(:each) do
    @episode = mock_model(Episode)
    @episode.stub!(:podcast_id).and_return("1")
    @episode.stub!(:title).and_return("1")
    @episode.stub!(:synopsis).and_return("MyText")
    @episode.stub!(:magnet).and_return("MyString")
    @episode.stub!(:published_at).and_return(Time.now)

    assigns[:episode] = @episode
  end

  it "should render attributes in <p>" do
    render "/episodes/show.html.erb"
    response.should have_text(/1/)
    response.should have_text(/MyText/)
    response.should have_text(/MyString/)
  end
end

