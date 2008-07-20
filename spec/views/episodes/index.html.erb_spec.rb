require File.dirname(__FILE__) + '/../../spec_helper'

describe "/episodes/index.html.erb" do
  before(:each) do
    episode_98 = mock_model(Episode)
    episode_98.should_receive(:podcast_id).and_return("1")
    episode_98.should_receive(:title).and_return("1")
    episode_98.should_receive(:synopsis).and_return("MyText")
    episode_98.should_receive(:magnet).and_return("MyString")
    episode_98.should_receive(:published_at).and_return(Time.now)
    episode_99 = mock_model(Episode)
    episode_99.should_receive(:podcast_id).and_return("1")
    episode_99.should_receive(:title).and_return("1")
    episode_99.should_receive(:synopsis).and_return("MyText")
    episode_99.should_receive(:magnet).and_return("MyString")
    episode_99.should_receive(:published_at).and_return(Time.now)

    assigns[:episodes] = [episode_98, episode_99]
  end

  it "should render list of episodes" do
    render "/episodes/index.html.erb"
    response.should have_tag("tr>td", "1", 2)
    response.should have_tag("tr>td", "MyText", 2)
    response.should have_tag("tr>td", "MyString", 2)
  end
end

