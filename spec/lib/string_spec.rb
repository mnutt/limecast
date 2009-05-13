require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe String do

  describe "#to_url" do
    it 'should remove the protocol from a url' do
      "http://google.com".to_url.should == "google.com"
    end

    it 'should remove trailing slashes' do
      "google.com/".to_url.should == "google.com"
    end

    it 'should remove the "www."' do
      "www.google.com".to_url.should == "google.com"
    end

    it 'should leave just the domain and tld of "http://www.google.com/"' do
      "http://www.google.com/".to_url.should == "google.com"
    end

    it 'should leave the subdomain of "mail.google.com"' do
      "http://mail.google.com/".to_url.should == "mail.google.com"
    end

    it 'should downcase the domain, but not rest of the url' do
      "http://mail.GooGle.com/UPPER".to_url.should == "mail.google.com/UPPER"
    end
  end

  describe "#increment and #increment!" do
    it 'should increment nothing to 1' do
      "Something".increment.should == "Something1"
    end
    
    it 'should increment the digits in the string' do
      "789".increment.should == "790"
    end

    it 'should pay attention to spacing' do
      "Foo bar 3".increment.should == "Foo bar 4"
    end

    it 'should increment digits' do
      " whateverrrr 99".increment.should == " whateverrrr 100"
    end
    
    it 'should set the original value with bang' do
      x = " foobar 123".increment!
      x.should == " foobar 124"
    end
    
  end

end

