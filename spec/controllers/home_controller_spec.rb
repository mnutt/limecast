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
        assigns(:surf_episode).should == @episode
      end

      it 'should not get an episode that the user has seen' do
        @user.surfed_episodes << @episode
        get :home
        assigns(:surf_episode).should == @episode2

        @user.surfed_episodes << @episode2
        get :home
        assigns(:surf_episode).should == @episode3
      end
    end

    describe "surfing to next episode" do
      before do
        @surf = lambda { post :surf, :direction => :next, :episode_id => @episode.id, :format => :js }
      end
      
      it 'should get the next episode' do
        @surf.call
        assigns(:surf_episode).should == @episode2
      end
      
      it 'should add the given episode to the user\'s list of surfed episodes' do
        @surf.should change(@user.surfed_episodes, :count).by(1)
        @user.surfed_episodes.last.should == @episode
      end
    end
    
    describe "surfing to previous sepisode" do
      it 'should get the previous episode' do
        post :surf, :direction => 'previous', :episode_id => @episode3.id, :format => :js
        assigns(:surf_episode).should == @episode2

        post :surf, :direction => 'previous', :episode_id => @episode2.id, :format => :js
        assigns(:surf_episode).should == @episode
      end
      
      it 'should add the given episode to the user\'s list of surfed episodes' do
        lambda {
          post :surf, :direction => 'previous', :episode_id => @episode3.id, :format => :js
        }.should change(@user.surfed_episodes, :size).by(1)
        @user.surfed_episodes.last.should == @episode3
      end
    end
  end
  
  describe "when not logged in" do
    before do
      session[:unclaimed_records] = {}
      session[:unclaimed_records]['UserSurfedEpisode'] = []
    end

    describe "surfing episodes on homepage" do
      it 'should get the latest episode' do
        get :home
        assigns(:surf_episode).should == @episode
      end

      it 'should not get an episode that the visitor has seen' do
        session[:unclaimed_records]['UserSurfedEpisode'] << UserSurfedEpisode.create(:episode => @episode)
        get :home
        assigns(:surf_episode).should == @episode2

        session[:unclaimed_records]['UserSurfedEpisode'] << UserSurfedEpisode.create(:episode => @episode2)
        get :home
        assigns(:surf_episode).should == @episode3
      end
    end

    describe "surfing to next episode" do
      before do
        @surf = lambda { post :surf, :direction => :next, :episode_id => @episode.id, :format => :js }
      end
      
      it 'should get the next episode' do
        @surf.call
        assigns(:surf_episode).should == @episode2
      end
      
      it 'should add the given episode to the user\'s list of surfed episodes' do
        @surf.should change(session[:unclaimed_records]['UserSurfedEpisode'], :size).by(1)
        session[:unclaimed_records]['UserSurfedEpisode'].last.should == UserSurfedEpisode.find_by_episode_id(@episode.id).id
      end
    end

    describe "surfing to previous episode" do
      it 'should get the previous episode' do
        post :surf, :direction => 'previous', :episode_id => @episode3.id, :format => :js
        assigns(:surf_episode).should == @episode2

        post :surf, :direction => 'previous', :episode_id => @episode2.id, :format => :js
        assigns(:surf_episode).should == @episode
      end
      
      it 'should add the given episode to the user\'s list of surfed episodes' do
        lambda {
          post :surf, :direction => 'previous', :episode_id => @episode3.id, :format => :js
        }.should change(session[:unclaimed_records]['UserSurfedEpisode'], :size).by(1)
        use = UserSurfedEpisode.find(session[:unclaimed_records]['UserSurfedEpisode'].last)
        use.episode.should == @episode3
      end
    end
  end
end
