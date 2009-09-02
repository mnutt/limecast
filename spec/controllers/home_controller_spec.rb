require File.dirname(__FILE__) + '/../spec_helper'

describe HomeController do
  before do
    @episode = Factory.create(:episode, :published_at => 3.days.ago, :sources => [Factory.create(:source, :published_at => 3.days.ago, :screenshot_file_size => 12345, :preview_file_size => 12345)])
    @episode2 = Factory.create(:episode, :published_at => 4.days.ago, :sources => [Factory.create(:source, :published_at => 4.days.ago, :screenshot_file_size => 12345, :preview_file_size => 12345)])
    @episode3 = Factory.create(:episode, :published_at => 5.days.ago, :sources => [Factory.create(:source, :published_at => 5.days.ago, :screenshot_file_size => 12345, :preview_file_size => 12345)])
    @surf_episode = SurfEpisode.create(:episode => @episode, :order => 1)
    @surf_episode2 = SurfEpisode.create(:episode => @episode2, :order => 2)
    @surf_episode3 = SurfEpisode.create(:episode => @episode3, :order => 3)
  end

  describe "surfing episodes on homepage" do
    it 'should get a random surf episode' do
      get :home
      [@episode, @episode2, @episode3].should include(assigns(:episode))
    end
  end

  describe "surfing to next episode" do
    before do
      @surf = lambda { post :surf, :direction => :next, :episode_id => @episode.id, :format => :js }
    end
    
    it 'should get the next episode' do
      @surf.call
      assigns(:episode).should == @episode2
    end
  end
  
  describe "surfing to previous sepisode" do
    it 'should get the previous episode' do
      post :surf, :direction => 'previous', :episode_id => @episode3.id, :format => :js
      assigns(:episode).should == @episode2

      post :surf, :direction => 'previous', :episode_id => @episode2.id, :format => :js
      assigns(:episode).should == @episode
    end
  end
end
