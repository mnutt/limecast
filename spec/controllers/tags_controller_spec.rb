require File.dirname(__FILE__) + '/../spec_helper'

describe TagsController do
  before(:each) do
    @tag = Factory.create(:tag, :name => 'video')
    @tag2 = Factory.create(:tag, :name => 'hd')
    @podcast = Factory.create(:podcast)
    @podcast2 = Factory.create(:podcast)
    @podcast2.tags << @tag
    @podcast2.save!
    login(@user)
  end

  describe "handling GET /tag/:tag/search" do
    def do_get(tag, query='')
      get :search, :tag => tag, :q => query
    end

    it "should be successful" do
      do_get(@tag.name)
      response.should be_success
    end

    it "should render show template" do
      do_get(@tag.name)
      response.should render_template('show')
    end

    it "should find all reviews" do
      Podcast.stub!(:search).and_return([@podcast, @podcast2])
      Podcast.should_receive(:search).and_return([@podcast, @podcast2])
      do_get(@tag.name)
    end

    it "should find all reviews with 'blah'" do
      Podcast.stub!(:search).and_return([@podcast])
      Podcast.should_receive(:search).and_return([@podcast, @podcast])
      do_get(@tag.name)
    end

  end

end
