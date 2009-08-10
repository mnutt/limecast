require File.dirname(__FILE__) + '/../spec_helper'

describe SearchController do
  describe "handling GET /search?q=the" do
    before(:each) do
      @podcast = Factory.create(:parsed_podcast)
    end

    def do_get
      get :show, :query => 'foooooobarrrr'
    end

    it "should be successful" do
      do_get
      response.should be_success
    end

    it "should assign expected variables" do
      do_get
      assigns(:podcasts).should == []
      assigns(:episodes).should == []
      assigns(:reviews).should == []
    end

    it "should render show template" do
      do_get
      response.should render_template('show')
    end
  end

  describe "handling GET /search?q=the+podcast:Diggnation" do

  end

end
