require File.dirname(__FILE__) + '/../../spec_helper'

describe "/episodes/edit.html.erb" do
  before do
    @episode = mock_model(Episode)
    @episode.stub!(:podcast_id).and_return("1")
    @episode.stub!(:title).and_return("1")
    @episode.stub!(:synopsis).and_return("MyText")
    @episode.stub!(:magnet).and_return("MyString")
    @episode.stub!(:published_at).and_return(Time.now)
    assigns[:episode] = @episode
  end

  it "should render edit form" do
    render "/episodes/edit.html.erb"
    
    response.should have_tag("form[action=#{episode_path(@episode)}][method=post]") do
      with_tag('input#episode_title[name=?]', "episode[title]")
      with_tag('textarea#episode_synopsis[name=?]', "episode[synopsis]")
      with_tag('input#episode_magnet[name=?]', "episode[magnet]")
    end
  end
end


