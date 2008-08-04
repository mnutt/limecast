require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Blacklist do
  before(:each) do
    @valid_attributes = {
      :domain => "value for domain"
    }
  end

  it "should create a new instance given valid attributes" do
    Blacklist.create!(@valid_attributes)
  end
end
