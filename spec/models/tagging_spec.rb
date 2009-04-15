require File.dirname(__FILE__) + '/../spec_helper'

describe Tagging, "being created" do
#  before do
#    @podcast = Factory.create(:podcast)
#  end
#
#  it 'should map a bad tag to good tag' do
#    good_tag = Tag.create :name => "good"
#    bad_tag  = Tag.create :name => "bad", :map_to => good_tag
#
#    tagging = Tagging.create :tag => bad_tag
#
#    tagging.tag.should == good_tag
#  end
#
#  it 'should allow any number of tags per podcast' do
#    adding_tagging = lambda { @podcast.tags << Factory.create(:tag) }
#
#    10.times { adding_tagging.should change(Tagging, :count).by(1) }
#  end
#
#  it 'should not allow duplicate taggings' do
#    tag = Factory.create(:tag)
#    adding_tagging = lambda { Tagging.create!(:podcast => @podcast, :tag => tag) }
#
#    adding_tagging.should change(Tagging, :count).by(1)
#    adding_tagging.should raise_error(ActiveRecord::RecordInvalid)
#  end

  it 'should find episodes older X minutes ago with the named scope helper' do
    t = Tagging.create :tag_id => 10, :podcast_id => 20, :created_at => 2.hours.ago

    ts = Tagging.created_at_least(1.hour.ago)
    ts.size.should == 1
    ts[0].should == t
  end

  it 'should be able to detect an unclaimed tagging' do
    t1 = Tagging.create :tag_id => 10, :podcast_id => 20

    t2 = Tagging.create :tag_id => 11, :podcast_id => 22
    ut = Factory.build :user_tagging, :tagging => t2
    ut.save(false)

    t1.reload.should be_unclaimed
    t2.reload.should_not be_unclaimed
  end
end

