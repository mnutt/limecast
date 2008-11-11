# require File.dirname(__FILE__) + '/../../../spec_helper'
#
# describe "/admin/episodes/index.html.erb" do
#   before(:each) do
#     episode_98 = mock_model(Episode)
#     episode_98.should_receive(:summary).and_return("MyText")
#     episode_98.should_receive(:published_at).and_return(Time.now)
#     episode_98.should_receive(:enclosure_url).and_return("MyString")
#     episode_98.should_receive(:created_at).and_return(Time.now)
#     episode_98.should_receive(:updated_at).and_return(Time.now)
#     episode_98.should_receive(:guid).and_return("MyString")
#     episode_98.should_receive(:enclosure_type).and_return("MyString")
#     episode_98.should_receive(:duration).and_return("1")
#     episode_98.should_receive(:title).and_return("MyString")
#     episode_99 = mock_model(Episode)
#     episode_99.should_receive(:summary).and_return("MyText")
#     episode_99.should_receive(:published_at).and_return(Time.now)
#     episode_99.should_receive(:enclosure_url).and_return("MyString")
#     episode_99.should_receive(:created_at).and_return(Time.now)
#     episode_99.should_receive(:updated_at).and_return(Time.now)
#     episode_99.should_receive(:guid).and_return("MyString")
#     episode_99.should_receive(:enclosure_type).and_return("MyString")
#     episode_99.should_receive(:duration).and_return("1")
#     episode_99.should_receive(:title).and_return("MyString")
#
#     assigns[:episodes] = [episode_98, episode_99]
#   end
#
#   it "should render list of admin_episodes" do
#     render "/admin/episodes/index.html.erb"
#     response.should have_tag("tr>td", "MyText", 2)
#     response.should have_tag("tr>td", "MyString", 2)
#     response.should have_tag("tr>td", "MyString", 2)
#     response.should have_tag("tr>td", "MyString", 2)
#     response.should have_tag("tr>td", "1", 2)
#     response.should have_tag("tr>td", "MyString", 2)
#   end
# end
#
