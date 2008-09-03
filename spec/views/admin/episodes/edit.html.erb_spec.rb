# require File.dirname(__FILE__) + '/../../../spec_helper'
# 
# describe "/admin/episodes/edit.html.erb" do
#   before do
#     @episode = mock_model(Episode)
#     @episode.stub!(:summary).and_return("MyText")
#     @episode.stub!(:published_at).and_return(Time.now)
#     @episode.stub!(:enclosure_url).and_return("MyString")
#     @episode.stub!(:created_at).and_return(Time.now)
#     @episode.stub!(:updated_at).and_return(Time.now)
#     @episode.stub!(:guid).and_return("MyString")
#     @episode.stub!(:enclosure_type).and_return("MyString")
#     @episode.stub!(:duration).and_return("1")
#     @episode.stub!(:title).and_return("MyString")
#     assigns[:episode] = @episode
#   end
# 
#   it "should render edit form" do
#     render "/admin/episodes/edit.html.erb"
# 
#     response.should have_tag("form[action=#{admin_episode_path(@episode)}][method=post]") do
#       with_tag('textarea#episode_summary[name=?]', "episode[summary]")
#       with_tag('input#episode_enclosure_url[name=?]', "episode[enclosure_url]")
#       with_tag('input#episode_guid[name=?]', "episode[guid]")
#       with_tag('input#episode_enclosure_type[name=?]', "episode[enclosure_type]")
#       with_tag('input#episode_duration[name=?]', "episode[duration]")
#       with_tag('input#episode_title[name=?]', "episode[title]")
#     end
#   end
# end
# 
# 
