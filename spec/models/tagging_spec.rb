require File.dirname(__FILE__) + '/../spec_helper'

describe Tagging, "being created" do
  before do
    @podcast = Factory.create(:podcast)
  end

  it 'should map a bad tag to good tag' do
    good_tag = Tag.create :name => "good"
    bad_tag  = Tag.create :name => "bad", :map_to => good_tag

    tagging = Tagging.create :tag => bad_tag

    tagging.tag.should == good_tag
  end

  # it 'should create a tag from a user' do
  #   user_tag = Tag.create :name => "user1", :user_id => 
  # end

  it 'should allow any number of tags per podcast' do
    adding_tagging = lambda { @podcast.tags << Factory.create(:tag) }

    10.times { adding_tagging.should change(Tagging, :count).by(1) }
  end

  it 'should not allow duplicate taggings' do
    tag = Factory.create(:tag)
    adding_tagging = lambda { Tagging.create!(:podcast => @podcast, :tag => tag) }

    adding_tagging.should change(Tagging, :count).by(1)
    adding_tagging.should raise_error(ActiveRecord::RecordInvalid)
  end

end

