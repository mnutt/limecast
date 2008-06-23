require File.dirname(__FILE__) + '/../../../spec_helper'

describe "/admin_podcasts/new.html.erb" do
  include Admin::PodcastsHelper
  
  before(:each) do
    @podcast = mock_model(Admin::Podcast)
    @podcast.stub!(:new_record?).and_return(true)
    @podcast.stub!(:title).and_return("MyString")
    @podcast.stub!(:site).and_return("MyString")
    @podcast.stub!(:feed).and_return("MyString")
    @podcast.stub!(:created_at).and_return(Time.now)
    @podcast.stub!(:updated_at).and_return(Time.now)
    @podcast.stub!(:feed_etag).and_return("MyString")
    @podcast.stub!(:user_id).and_return("MyString")
    @podcast.stub!(:description).and_return("MyText")
    @podcast.stub!(:language).and_return("MyString")
    assigns[:podcast] = @podcast
  end

  it "should render new form" do
    render "/admin_podcasts/new.html.erb"
    
    response.should have_tag("form[action=?][method=post]", admin_podcasts_path) do
      with_tag("input#podcast_title[name=?]", "podcast[title]")
      with_tag("input#podcast_site[name=?]", "podcast[site]")
      with_tag("input#podcast_feed[name=?]", "podcast[feed]")
      with_tag("input#podcast_feed_etag[name=?]", "podcast[feed_etag]")
      with_tag("textarea#podcast_description[name=?]", "podcast[description]")
      with_tag("input#podcast_language[name=?]", "podcast[language]")
    end
  end
end


