require File.dirname(__FILE__) + '/../spec_helper'

describe SurfEpisode do
  describe "order" do
    before do
      @surf_episode = SurfEpisode.new(:episode => Factory.create(:episode))
      @surf_episode2 = SurfEpisode.new(:episode => Factory.create(:episode))
      @surf_episode3 = SurfEpisode.new(:episode => Factory.create(:episode))
    end

    it 'should autoset the order' do
      [@surf_episode, @surf_episode2, @surf_episode3].each_with_index do |se, i|
        lambda { se.save }.should change { se.order }
        se.order.should == i + 1
      end
    end
  end

  describe "reset queue" do
    before do
      @episode = Factory.create(:episode, :published_at => 30.days.ago, :sources => [Factory.create(:source, :published_at => 3.days.ago, :screenshot_file_size => 12345, :preview_file_size => 12345)])
      @episode2 = Factory.create(:episode, :published_at => 10.days.ago, :sources => [Factory.create(:source, :published_at => 4.days.ago, :screenshot_file_size => 12345, :preview_file_size => 12345)])
      @episode3 = Factory.create(:episode, :published_at => 5.days.ago, :sources => [Factory.create(:source, :published_at => 5.days.ago, :screenshot_file_size => 12345, :preview_file_size => 12345)])
      @episode4 = Factory.create(:episode, :published_at => 1.day.ago, :sources => [Factory.create(:source, :published_at => 5.days.ago, :screenshot_file_size => 12345, :preview_file_size => 12345)])
      @episode5 = Factory.create(:episode, :published_at => 1.day.from_now, :sources => [Factory.create(:source, :published_at => 5.days.ago, :screenshot_file_size => 12345, :preview_file_size => 12345)])
    end
    
    it 'should reset the queue to all episodes within the last 10 days' do
      lambda { SurfEpisode.reset_queue }.should change(SurfEpisode, :count).by(3)
      SurfEpisode.all.map(&:episode).sort_by { |e| e.published_at }.should == [@episode2, @episode3, @episode4]
    end
  end
end
