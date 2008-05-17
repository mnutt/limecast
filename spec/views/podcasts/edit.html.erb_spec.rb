require File.dirname(__FILE__) + '/../../spec_helper'

describe "/podcasts/edit.html.erb" do
  include PodcastsHelper
  
  before do
    @podcast = mock_model(Podcast)
    @podcast.stub!(:title).and_return("MyString")
    @podcast.stub!(:site).and_return("MyString")
    @podcast.stub!(:feed).and_return("MyString")
    @podcast.stub!(:logo_file_name).and_return("MyString")
    @podcast.stub!(:logo_content_type).and_return("MyString")
    @podcast.stub!(:logo_file_size).and_return("MyString")
    assigns[:podcast] = @podcast
  end

  it "should render edit form" do
    render "/podcasts/edit.html.erb"
    
    response.should have_tag("form[action=#{podcast_path(@podcast)}][method=post]") do
      with_tag('input#podcast_title[name=?]', "podcast[title]")
      with_tag('input#podcast_site[name=?]', "podcast[site]")
      with_tag('input#podcast_feed[name=?]', "podcast[feed]")
      with_tag('input#podcast_logo_file_name[name=?]', "podcast[logo_file_name]")
      with_tag('input#podcast_logo_content_type[name=?]', "podcast[logo_content_type]")
      with_tag('input#podcast_logo_file_size[name=?]', "podcast[logo_file_size]")
    end
  end
end


