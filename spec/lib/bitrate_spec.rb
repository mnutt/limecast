require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Bitrate do
  it 'should convert a size into kilobits per second' do
    Bitrate.new(100).to_s.should == "100kbps"
  end

  it 'should convert an even size without decimal' do
    Bitrate.new(200000).to_s.should == "200mbps"
  end

  it 'should convert a decimal size' do
    Bitrate.new(200100).to_s.should == "200.1mbps"
  end
end
