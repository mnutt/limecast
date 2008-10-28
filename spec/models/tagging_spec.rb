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

  it 'should not allow any more than two category tags per podcast' do
    adding_tagging = lambda { @podcast.tags << Factory.create(:tag, :category => true) }

    adding_tagging.should change(Tagging, :count).by(1)
    adding_tagging.should change(Tagging, :count).by(1)
    adding_tagging.should raise_error(ActiveRecord::RecordInvalid)
  end

  it 'should allow any number of non category tags per podcast' do
    adding_tagging = lambda { @podcast.tags << Factory.create(:tag) }

    10.times { adding_tagging.should change(Tagging, :count).by(1) }
  end

  it 'should allow two category tags and any number of non category tags per podcast' do
    2.times do
      lambda { @podcast.tags << Factory.create(:tag, :category => true) }.should change(Tagging, :count).by(1)
    end

    11.times do
      lambda { @podcast.tags << Factory.create(:tag) }.should change(Tagging, :count).by(1)
    end
  end

  it 'should not allow duplicate taggings' do
    tag = Factory.create(:tag)
    adding_tagging = lambda { Tagging.create!(:taggable => @podcast, :tag => tag) }

    adding_tagging.should change(Tagging, :count).by(1)
    adding_tagging.should raise_error(ActiveRecord::RecordInvalid)
  end
end

