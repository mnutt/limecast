require File.dirname(__FILE__) + '/../spec_helper'

describe SearchController do
  # TODO find a faster solution for testing with sphinx than with_sphinx to get real search results
  describe "handling GET /search?q=the" do
    before(:each) do
      @podcast = Factory.create(:parsed_podcast)
    end

    def do_get
      get :index, :q => 'the'
    end

    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should assign expected variables" do
      do_get
      assigns(:podcasts).should == []
      assigns(:feeds).should == []
      assigns(:episodes).should == []
      assigns(:reviews).should == []
    end

    it "should render index template" do
      do_get
      response.should render_template('index')
    end
  end

  describe "handling GET /search?q=the+podcast:Diggnation" do

  end

end
