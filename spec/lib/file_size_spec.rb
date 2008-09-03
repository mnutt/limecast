require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FileSize do

  it 'should be accessible via Integer#to_file_size' do
    100.to_file_size.class.should == FileSize
  end

  it 'should return an empty string for a negative file size' do
    -10.to_file_size.to_s.should be_empty
  end

  it 'should never show more than one unit' do
    (1.gigabyte + 1.megabyte + 1.kilobyte).to_file_size.to_s.split.length.should == 2
  end

end

