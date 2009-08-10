require File.dirname(__FILE__) + '/../spec_helper'

describe UserTagging, "being created" do
  before(:each) do
    @podcast = Factory.create(:podcast)
    @tag = Factory.create(:tag)
    @tagging = Factory.create(:tagging, :tag => @tag, :podcast => @podcast)
    @user1 = Factory.create(:user)
    @user2 = Factory.create(:user)
  end

  it 'should not allow duplicate user taggings' do
    adding_user_tagging = lambda { UserTagging.create!(:tagging => @tagging, :user => @user1) }

    adding_user_tagging.should change(UserTagging, :count).by(1)
    adding_user_tagging.should raise_error(ActiveRecord::RecordInvalid)
  end

  it 'should keep track of users who add a tagging' do
    @tagging.users.should == []

    lambda { UserTagging.create!(:tagging => @tagging, :user => @user1) }.should change(UserTagging, :count).by(1)
    lambda { UserTagging.create!(:tagging => @tagging, :user => @user2) }.should change(UserTagging, :count).by(1)

    @tagging.reload.users.should == [@user1, @user2]
  end

  it 'should raise an error if a regular user adds more than 8 UserTaggings' do
    8.times do |i|
      tag = Factory.create(:tag)
      tagging = Factory.create(:tagging, :tag => tag, :podcast => @podcast)
      lambda { UserTagging.create!(:tagging => tagging, :user => @user1) }.should change(UserTagging, :count).by(1)
    end

    user_tagging = UserTagging.new(:tagging => @tagging, :user => @user1)
    user_tagging.should_not be_valid
    user_tagging.errors.on(:user).should include("is only allowed to make 8 tags for this podcast")
  end

  it 'should allow a podcast editor to add infinite UserTaggings' do
    @podcast.update_attributes(:author_email => @user1.email)

    50.times do |i|
      tag = Factory.create(:tag)
      tagging = Factory.create(:tagging, :tag => tag, :podcast => @podcast)
      lambda { UserTagging.create!(:tagging => tagging, :user => @user1) }.should change(UserTagging, :count).by(1)
    end
  end
end

