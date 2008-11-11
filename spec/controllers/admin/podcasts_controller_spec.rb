# require File.dirname(__FILE__) + '/../../spec_helper'
#
# describe Admin::PodcastsController do
#   describe "handling GET /admin_podcasts" do
#
#     before(:each) do
#       @podcast = mock_model(Admin::Podcast)
#       Admin::Podcast.stub!(:find).and_return([@podcast])
#     end
#
#     def do_get
#       get :index
#     end
#
#     it "should be successful" do
#       do_get
#       response.should be_success
#     end
#
#     it "should render index template" do
#       do_get
#       response.should render_template('index')
#     end
#
#     it "should find all admin_podcasts" do
#       Admin::Podcast.should_receive(:find).with(:all).and_return([@podcast])
#       do_get
#     end
#
#     it "should assign the found admin_podcasts for the view" do
#       do_get
#       assigns[:admin_podcasts].should == [@podcast]
#     end
#   end
#
#   describe "handling GET /admin_podcasts.xml" do
#
#     before(:each) do
#       @podcasts = mock("Array of Admin::Podcasts", :to_xml => "XML")
#       Admin::Podcast.stub!(:find).and_return(@podcasts)
#     end
#
#     def do_get
#       @request.env["HTTP_ACCEPT"] = "application/xml"
#       get :index
#     end
#
#     it "should be successful" do
#       do_get
#       response.should be_success
#     end
#
#     it "should find all admin_podcasts" do
#       Admin::Podcast.should_receive(:find).with(:all).and_return(@podcasts)
#       do_get
#     end
#
#     it "should render the found admin_podcasts as xml" do
#       @podcasts.should_receive(:to_xml).and_return("XML")
#       do_get
#       response.body.should == "XML"
#     end
#   end
#
#   describe "handling GET /admin_podcasts/1" do
#
#     before(:each) do
#       @podcast = mock_model(Admin::Podcast)
#       Admin::Podcast.stub!(:find).and_return(@podcast)
#     end
#
#     def do_get
#       get :show, :id => "1"
#     end
#
#     it "should be successful" do
#       do_get
#       response.should be_success
#     end
#
#     it "should render show template" do
#       do_get
#       response.should render_template('show')
#     end
#
#     it "should find the podcast requested" do
#       Admin::Podcast.should_receive(:find).with("1").and_return(@podcast)
#       do_get
#     end
#
#     it "should assign the found podcast for the view" do
#       do_get
#       assigns[:podcast].should equal(@podcast)
#     end
#   end
#
#   describe "handling GET /admin_podcasts/1.xml" do
#
#     before(:each) do
#       @podcast = mock_model(Admin::Podcast, :to_xml => "XML")
#       Admin::Podcast.stub!(:find).and_return(@podcast)
#     end
#
#     def do_get
#       @request.env["HTTP_ACCEPT"] = "application/xml"
#       get :show, :id => "1"
#     end
#
#     it "should be successful" do
#       do_get
#       response.should be_success
#     end
#
#     it "should find the podcast requested" do
#       Admin::Podcast.should_receive(:find).with("1").and_return(@podcast)
#       do_get
#     end
#
#     it "should render the found podcast as xml" do
#       @podcast.should_receive(:to_xml).and_return("XML")
#       do_get
#       response.body.should == "XML"
#     end
#   end
#
#   describe "handling GET /admin_podcasts/new" do
#
#     before(:each) do
#       @podcast = mock_model(Admin::Podcast)
#       Admin::Podcast.stub!(:new).and_return(@podcast)
#     end
#
#     def do_get
#       get :new
#     end
#
#     it "should be successful" do
#       do_get
#       response.should be_success
#     end
#
#     it "should render new template" do
#       do_get
#       response.should render_template('new')
#     end
#
#     it "should create an new podcast" do
#       Admin::Podcast.should_receive(:new).and_return(@podcast)
#       do_get
#     end
#
#     it "should not save the new podcast" do
#       @podcast.should_not_receive(:save)
#       do_get
#     end
#
#     it "should assign the new podcast for the view" do
#       do_get
#       assigns[:podcast].should equal(@podcast)
#     end
#   end
#
#   describe "handling GET /admin_podcasts/1/edit" do
#
#     before(:each) do
#       @podcast = mock_model(Admin::Podcast)
#       Admin::Podcast.stub!(:find).and_return(@podcast)
#     end
#
#     def do_get
#       get :edit, :id => "1"
#     end
#
#     it "should be successful" do
#       do_get
#       response.should be_success
#     end
#
#     it "should render edit template" do
#       do_get
#       response.should render_template('edit')
#     end
#
#     it "should find the podcast requested" do
#       Admin::Podcast.should_receive(:find).and_return(@podcast)
#       do_get
#     end
#
#     it "should assign the found Admin::Podcast for the view" do
#       do_get
#       assigns[:podcast].should equal(@podcast)
#     end
#   end
#
#   describe "handling POST /admin_podcasts" do
#
#     before(:each) do
#       @podcast = mock_model(Admin::Podcast, :to_param => "1")
#       Admin::Podcast.stub!(:new).and_return(@podcast)
#     end
#
#     describe "with successful save" do
#
#       def do_post
#         @podcast.should_receive(:save).and_return(true)
#         post :create, :podcast => {}
#       end
#
#       it "should create a new podcast" do
#         Admin::Podcast.should_receive(:new).with({}).and_return(@podcast)
#         do_post
#       end
#
#       it "should redirect to the new podcast" do
#         do_post
#         response.should redirect_to(admin_podcast_url("1"))
#       end
#
#     end
#
#     describe "with failed save" do
#
#       def do_post
#         @podcast.should_receive(:save).and_return(false)
#         post :create, :podcast => {}
#       end
#
#       it "should re-render 'new'" do
#         do_post
#         response.should render_template('new')
#       end
#
#     end
#   end
#
#   describe "handling PUT /admin_podcasts/1" do
#
#     before(:each) do
#       @podcast = mock_model(Admin::Podcast, :to_param => "1")
#       Admin::Podcast.stub!(:find).and_return(@podcast)
#     end
#
#     describe "with successful update" do
#
#       def do_put
#         @podcast.should_receive(:update_attributes).and_return(true)
#         put :update, :id => "1"
#       end
#
#       it "should find the podcast requested" do
#         Admin::Podcast.should_receive(:find).with("1").and_return(@podcast)
#         do_put
#       end
#
#       it "should update the found podcast" do
#         do_put
#         assigns(:podcast).should equal(@podcast)
#       end
#
#       it "should assign the found podcast for the view" do
#         do_put
#         assigns(:podcast).should equal(@podcast)
#       end
#
#       it "should redirect to the podcast" do
#         do_put
#         response.should redirect_to(admin_podcast_url("1"))
#       end
#
#     end
#
#     describe "with failed update" do
#
#       def do_put
#         @podcast.should_receive(:update_attributes).and_return(false)
#         put :update, :id => "1"
#       end
#
#       it "should re-render 'edit'" do
#         do_put
#         response.should render_template('edit')
#       end
#
#     end
#   end
#
#   describe "handling DELETE /admin_podcasts/1" do
#
#     before(:each) do
#       @podcast = mock_model(Admin::Podcast, :destroy => true)
#       Admin::Podcast.stub!(:find).and_return(@podcast)
#     end
#
#     def do_delete
#       delete :destroy, :id => "1"
#     end
#
#     it "should find the podcast requested" do
#       Admin::Podcast.should_receive(:find).with("1").and_return(@podcast)
#       do_delete
#     end
#
#     it "should call destroy on the found podcast" do
#       @podcast.should_receive(:destroy)
#       do_delete
#     end
#
#     it "should redirect to the admin_podcasts list" do
#       do_delete
#       response.should redirect_to(admin_podcasts_url)
#     end
#   end
# end
