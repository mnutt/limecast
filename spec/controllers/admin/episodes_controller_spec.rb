# require File.dirname(__FILE__) + '/../../spec_helper'
#
# describe Admin::EpisodesController do
#   describe "handling GET /admin_episodes" do
#
#     before(:each) do
#       @episode = mock_model(Admin::Episode)
#       Admin::Episode.stub!(:find).and_return([@episode])
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
#     it "should find all admin_episodes" do
#       Admin::Episode.should_receive(:find).with(:all).and_return([@episode])
#       do_get
#     end
#
#     it "should assign the found admin_episodes for the view" do
#       do_get
#       assigns[:admin_episodes].should == [@episode]
#     end
#   end
#
#   describe "handling GET /admin_episodes.xml" do
#
#     before(:each) do
#       @episodes = mock("Array of Admin::Episodes", :to_xml => "XML")
#       Admin::Episode.stub!(:find).and_return(@episodes)
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
#     it "should find all admin_episodes" do
#       Admin::Episode.should_receive(:find).with(:all).and_return(@episodes)
#       do_get
#     end
#
#     it "should render the found admin_episodes as xml" do
#       @episodes.should_receive(:to_xml).and_return("XML")
#       do_get
#       response.body.should == "XML"
#     end
#   end
#
#   describe "handling GET /admin_episodes/1" do
#
#     before(:each) do
#       @episode = mock_model(Admin::Episode)
#       Admin::Episode.stub!(:find).and_return(@episode)
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
#     it "should find the episode requested" do
#       Admin::Episode.should_receive(:find).with("1").and_return(@episode)
#       do_get
#     end
#
#     it "should assign the found episode for the view" do
#       do_get
#       assigns[:episode].should equal(@episode)
#     end
#   end
#
#   describe "handling GET /admin_episodes/1.xml" do
#
#     before(:each) do
#       @episode = mock_model(Admin::Episode, :to_xml => "XML")
#       Admin::Episode.stub!(:find).and_return(@episode)
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
#     it "should find the episode requested" do
#       Admin::Episode.should_receive(:find).with("1").and_return(@episode)
#       do_get
#     end
#
#     it "should render the found episode as xml" do
#       @episode.should_receive(:to_xml).and_return("XML")
#       do_get
#       response.body.should == "XML"
#     end
#   end
#
#   describe "handling GET /admin_episodes/new" do
#
#     before(:each) do
#       @episode = mock_model(Admin::Episode)
#       Admin::Episode.stub!(:new).and_return(@episode)
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
#     it "should create an new episode" do
#       Admin::Episode.should_receive(:new).and_return(@episode)
#       do_get
#     end
#
#     it "should not save the new episode" do
#       @episode.should_not_receive(:save)
#       do_get
#     end
#
#     it "should assign the new episode for the view" do
#       do_get
#       assigns[:episode].should equal(@episode)
#     end
#   end
#
#   describe "handling GET /admin_episodes/1/edit" do
#
#     before(:each) do
#       @episode = mock_model(Admin::Episode)
#       Admin::Episode.stub!(:find).and_return(@episode)
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
#     it "should find the episode requested" do
#       Admin::Episode.should_receive(:find).and_return(@episode)
#       do_get
#     end
#
#     it "should assign the found Admin::Episode for the view" do
#       do_get
#       assigns[:episode].should equal(@episode)
#     end
#   end
#
#   describe "handling POST /admin_episodes" do
#
#     before(:each) do
#       @episode = mock_model(Admin::Episode, :to_param => "1")
#       Admin::Episode.stub!(:new).and_return(@episode)
#     end
#
#     describe "with successful save" do
#
#       def do_post
#         @episode.should_receive(:save).and_return(true)
#         post :create, :episode => {}
#       end
#
#       it "should create a new episode" do
#         Admin::Episode.should_receive(:new).with({}).and_return(@episode)
#         do_post
#       end
#
#       it "should redirect to the new episode" do
#         do_post
#         response.should redirect_to(admin_episode_url("1"))
#       end
#
#     end
#
#     describe "with failed save" do
#
#       def do_post
#         @episode.should_receive(:save).and_return(false)
#         post :create, :episode => {}
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
#   describe "handling PUT /admin_episodes/1" do
#
#     before(:each) do
#       @episode = mock_model(Admin::Episode, :to_param => "1")
#       Admin::Episode.stub!(:find).and_return(@episode)
#     end
#
#     describe "with successful update" do
#
#       def do_put
#         @episode.should_receive(:update_attributes).and_return(true)
#         put :update, :id => "1"
#       end
#
#       it "should find the episode requested" do
#         Admin::Episode.should_receive(:find).with("1").and_return(@episode)
#         do_put
#       end
#
#       it "should update the found episode" do
#         do_put
#         assigns(:episode).should equal(@episode)
#       end
#
#       it "should assign the found episode for the view" do
#         do_put
#         assigns(:episode).should equal(@episode)
#       end
#
#       it "should redirect to the episode" do
#         do_put
#         response.should redirect_to(admin_episode_url("1"))
#       end
#
#     end
#
#     describe "with failed update" do
#
#       def do_put
#         @episode.should_receive(:update_attributes).and_return(false)
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
#   describe "handling DELETE /admin_episodes/1" do
#
#     before(:each) do
#       @episode = mock_model(Admin::Episode, :destroy => true)
#       Admin::Episode.stub!(:find).and_return(@episode)
#     end
#
#     def do_delete
#       delete :destroy, :id => "1"
#     end
#
#     it "should find the episode requested" do
#       Admin::Episode.should_receive(:find).with("1").and_return(@episode)
#       do_delete
#     end
#
#     it "should call destroy on the found episode" do
#       @episode.should_receive(:destroy)
#       do_delete
#     end
#
#     it "should redirect to the admin_episodes list" do
#       do_delete
#       response.should redirect_to(admin_episodes_url)
#     end
#   end
# end
