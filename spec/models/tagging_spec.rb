require File.dirname(__FILE__) + '/../spec_helper'

describe Tagging, "being created" do
  it 'should map a bad tag to good tag' do
    good_tag = Tag.create :name => "good"
    bad_tag  = Tag.create :name => "bad", :map_to => good_tag
    
    tagging = Tagging.create :tag => bad_tag

    tagging.tag.should == good_tag
  end
end

