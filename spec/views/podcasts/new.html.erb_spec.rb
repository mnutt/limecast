require File.dirname(__FILE__) + '/../../spec_helper'

describe "/podcasts/new.html.erb" do
  
  before(:each) do
    @podcast = mock_model(Podcast)
    @podcast.stub!(:new_record?).and_return(true)
    @podcast.stub!(:title).and_return("MyString")
    @podcast.stub!(:site).and_return("MyString")
    @podcast.stub!(:feed).and_return("MyString")
    @podcast.stub!(:logo_file_name).and_return("MyString")
    @podcast.stub!(:logo_content_type).and_return("MyString")
    @podcast.stub!(:logo_file_size).and_return("MyString")
    assigns[:podcast] = @podcast
  end

  it "should render new form" do
    render "/podcasts/new.html.erb"
    
    response.should have_tag("form[action=?][method=post]", podcasts_path) do
      with_tag("input#podcast_title[name=?]", "podcast[title]")
      with_tag("input#podcast_site[name=?]", "podcast[site]")
      with_tag("input#podcast_feed[name=?]", "podcast[feed]")
      with_tag("input#podcast_logo_file_name[name=?]", "podcast[logo_file_name]")
      with_tag("input#podcast_logo_content_type[name=?]", "podcast[logo_content_type]")
      with_tag("input#podcast_logo_file_size[name=?]", "podcast[logo_file_size]")
    end
  end
end


