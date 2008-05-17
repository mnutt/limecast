require File.dirname(__FILE__) + '/../../spec_helper'

describe "/episodes/new.html.erb" do
  include EpisodesHelper
  
  before(:each) do
    @episode = mock_model(Episode)
    @episode.stub!(:new_record?).and_return(true)
    @episode.stub!(:podcast_id).and_return("1")
    @episode.stub!(:title).and_return("1")
    @episode.stub!(:synopsis).and_return("MyText")
    @episode.stub!(:magnet).and_return("MyString")
    @episode.stub!(:published_at).and_return(Time.now)
    assigns[:episode] = @episode
  end

  it "should render new form" do
    render "/episodes/new.html.erb"
    
    response.should have_tag("form[action=?][method=post]", episodes_path) do
      with_tag("input#episode_title[name=?]", "episode[title]")
      with_tag("textarea#episode_synopsis[name=?]", "episode[synopsis]")
      with_tag("input#episode_magnet[name=?]", "episode[magnet]")
    end
  end
end


