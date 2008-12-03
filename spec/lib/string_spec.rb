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

end

