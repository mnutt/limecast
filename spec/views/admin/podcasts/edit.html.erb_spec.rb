# require File.dirname(__FILE__) + '/../../../spec_helper'
#
# describe "/admin_podcasts/edit.html.erb" do
#   before do
#     @podcast = mock_model(Podcast)
#     @podcast.stub!(:title).and_return("MyString")
#     @podcast.stub!(:site).and_return("MyString")
#     @podcast.stub!(:feed).and_return("MyString")
#     @podcast.stub!(:itunes_link).and_return("MyString")
#     @podcast.stub!(:logo_link).and_return("MyString")
#     @podcast.stub!(:tag_list).and_return("MyString")
#     @podcast.stub!(:created_at).and_return(Time.now)
#     @podcast.stub!(:updated_at).and_return(Time.now)
#     @podcast.stub!(:feed_etag).and_return("MyString")
#     @podcast.stub!(:user_id).and_return("MyString")
#     @podcast.stub!(:description).and_return("MyText")
#     @podcast.stub!(:language).and_return("MyString")
#     assigns[:podcast] = @podcast
#   end
#
#   it "should render edit form" do
#     render "/admin/podcasts/edit.html.erb"
#
#     response.should have_tag("form[action=#{admin_podcast_path(@podcast)}][method=post]") do
#       with_tag('input#podcast_title[name=?]', "podcast[title]")
#       with_tag('input#podcast_site[name=?]', "podcast[site]")
#       with_tag('input#podcast_feed[name=?]', "podcast[feed]")
#       with_tag('input#podcast_feed_etag[name=?]', "podcast[feed_etag]")
#       with_tag('textarea#podcast_description[name=?]', "podcast[description]")
#       with_tag('input#podcast_language[name=?]', "podcast[language]")
#     end
#   end
# end
