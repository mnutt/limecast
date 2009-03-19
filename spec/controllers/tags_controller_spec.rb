require File.dirname(__FILE__) + '/../spec_helper'

describe TagsController do
  before(:each) do
    @tag = Factory.create(:tag, :name => 'video')
    @tag2 = Factory.create(:tag, :name => 'hd')
    @podcast = Factory.create(:podcast)
    @podcast2 = Factory.create(:podcast)
    @podcast2.tags << @tag
    @podcast2.save!
    login(@user)
  end
end
