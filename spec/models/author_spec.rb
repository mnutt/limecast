require File.dirname(__FILE__) + '/../spec_helper'

describe Author do
  describe 'clean_url' do
    it 'should sanitize and autoset the clean_url from name if clean_url is blank' do
      Author.create(:name => 'A. Author', :email => 'a@b.com').clean_url.should == "A_Author"
    end
    
    it 'should sanitize crazy clean_urls' do
      Author.create(:name => 'A *Author1234_____..!', :email => 'a@b.com').clean_url.should == "A_Author1234_"
    end
    
    it 'should not autoset the clean_url if clean_url is NOT blank' do
      a = Author.create(:name => 'A. Author', :email => 'a@b.com', :clean_url => 'aauthor')
      a.clean_url.should == 'aauthor'
    end
    
    it 'should autoincrement if the clean_url already exists' do
      Author.create(:email => 'an_author@b.com', :clean_url => 'an_author').clean_url.should == "an_author"
      Author.create(:email => 'another_author@b.com', :clean_url => 'an_author').clean_url.should == "an_author2"
    end
  end

  describe 'name' do
    it 'should sanitize the name in case it is an email' do
      Author.create(:name => 'a@b.com').name.should == 'a'
      Author.create(:email => 'a@b.com').name.should == 'a'
    end

    it 'should be set to first part of email if nil' do
      a = Author.create(:email => 'a@b.com')
      a.name.should == 'a'
    end
    
    it 'should autoincrement if the name already exists' do
      Author.create(:email => 'an_author@b.com', :name => 'An Author').name.should == "An Author"
      Author.create(:email => 'another_author@b.com', :name => 'An Author').name.should == "An Author (2)"
    end
  end

  describe 'validation' do
    it 'should not allow an author to be created without an email' do
      lambda do
        a = Author.create(:email => '', :name => 'ccc')
        a.should_not be_valid
        a.errors.on(:email).should include("can't be blank")
      end.should_not change(Author, :count)
    end
  end
end

