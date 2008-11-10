require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Favorite do
  before(:each) do
    @user = Factory.create(:user)
    @podcast = Factory.create(:podcast)
    @episode = Factory.create(:episode, :podcast_id => @podcast.id)
  end

  def do_favorite
    @user.favorites.create(:episode => @episode)
  end

  describe "added to an episode" do
    it "should increase episode's favorites by 1" do
      lambda { do_favorite }.should change { @episode.favorites.count }.by(1)
    end
  end
end
