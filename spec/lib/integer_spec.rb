require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Integer do
  it 'should format a number into a string with commas' do
    1.to_formatted_s.should == '1'
    10.to_formatted_s.should == '10'
    100.to_formatted_s.should == '100'
    1000.to_formatted_s.should == '1,000'
    10000.to_formatted_s.should == '10,000'
    100000.to_formatted_s.should == '100,000'
    1000000.to_formatted_s.should == '1,000,000'
  end
end
