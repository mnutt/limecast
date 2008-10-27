require File.dirname(__FILE__) + '/../spec_helper'

describe Tag, "being created" do
  it 'should allow an alphanumeric name' do
    lambda {
      Factory.create(:tag, :name => "abc123")
    }.should change(Tag, :count).by(1)
  end

  it 'should allow a name with length 1' do
    lambda {
      Factory.create(:tag, :name => "a")
    }.should change(Tag, :count).by(1)
  end

  it 'should allow a name with length 32' do
    lambda {
      Factory.create(:tag, :name => "a" * 32)
    }.should change(Tag, :count).by(1)
  end

  it 'should now allow uppercase characters in the name' do
    lambda {
      Factory.create(:tag, :name => "ABC 123")
    }.should raise_error(ActiveRecord::RecordInvalid)
  end

  it 'should now allow spaces in the name' do
    lambda {
      Factory.create(:tag, :name => "abc 123")
    }.should raise_error(ActiveRecord::RecordInvalid)
  end

  it 'should not allow a name with invalid characters' do
    lambda {
      Factory.create(:tag, :name => "!#%$^")
    }.should raise_error(ActiveRecord::RecordInvalid)
  end

  it 'should not allow a name greater than 32 chars' do
    lambda {
      Factory.create(:tag, :name => "a"*33)
    }.should raise_error(ActiveRecord::RecordInvalid)
  end

  it 'should not allow a blank name' do
    lambda {
      Factory.create(:tag, :name => "")
    }.should raise_error(ActiveRecord::RecordInvalid)
  end
end

