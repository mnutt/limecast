require File.dirname(__FILE__) + '/../spec_helper'

describe HomeController do
  before do
    @episode = Factory.create(:episode, :published_at => 7.days.ago, :sources => [Factory.create(:source, :screenshot_file_size => 12345, :preview_file_size => 12345)])
    @episode2 = Factory.create(:episode, :published_at => 8.days.ago, :sources => [Factory.create(:source, :screenshot_file_size => 12345, :preview_file_size => 12345)])
    @episode3 = Factory.create(:episode, :published_at => 9.days.ago, :sources => [Factory.create(:source, :screenshot_file_size => 12345, :preview_file_size => 12345)])
  end

  describe "when logged in" do
    before do
      @user = Factory.create(:user)
      login @user
    end

    describe "surfing episodes on homepage" do
      it 'should get the latest episode' do
        get :home
        assigns(:surfed_episode).should == @episode
      end

      it 'should not get an episode that the user has seen' do
        @user.surfed_episodes << @episode
        get :home
        assigns(:surfed_episode).should == @episode2

        @user.surfed_episodes << @episode2
        get :home
        assigns(:surfed_episode).should == @episode3
      end
    end

    describe "surfing to next episode" do
      before do
        @surf = lambda { post :surf, :episode_id => @episode.id, :format => :js }
      end
      
      it 'should get the next episode' do
        @surf.call
        assigns(:surfed_episode).should == @episode2
      end
      
      it 'should add the given episode to the user\'s list of surfed episodes' do
        @surf.should change(@user.surfed_episodes, :count).by(1)
        @user.surfed_episodes.last.should == @episode
      end
    end
  end
  
  describe "when not logged in" do
    it 'should work' do
      true
    end
  end
end
