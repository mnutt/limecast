require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Date do

  describe "new standard format" do
    it 'should not have more than 1 space grouped together' do
      date_loop do |date|
        date.to_s.should_not match(/\s{2,}/)
      end
    end

    it 'should not have any leading 0s' do
      date_loop do |date|
        date.to_s.should_not match(/\s0/)
      end
    end

    it 'should show year first' do
      date_loop do |date|
        date.to_s.split[0].should == date.year.to_s
      end
    end

    it 'should show day last' do
      date_loop do |date|
        date.to_s.split[2].should == date.day.to_s
      end
    end

    it 'should show 3 letter abbreviations for month names' do
      date_loop do |date|
        date.to_s.split[1].length.should == 3
      end
    end

    it 'should show the full, four digit year' do
      date_loop do |date|
        date.to_s.split[0].length.should == 4
      end
    end

    it 'should have the first letter of the month capitalized with the rest lowercased' do
      date_loop do |date|
        date.to_s.split[1].should match(/[A-Z][a-z]+/)
      end
    end
  end

  describe "new url format" do
    it 'should not have any spaces' do
      date_loop do |date|
        date.to_s(:url).should_not match(/\s/)
      end
    end

    it 'should have every word separated by dashes' do
      date_loop do |date|
        date.to_s(:url).split("-").length.should == 3
      end
    end

    it 'should not have more than 1 dash grouped together' do
      date_loop do |date|
        date.to_s.should_not match(/\s{2,}/)
      end
    end

    it 'should not have any leading 0s' do
      date_loop do |date|
        date.to_s(:url).should_not match(/-0/)
      end
    end

    it 'should show year first' do
      date_loop do |date|
        date.to_s(:url).split("-")[0].should == date.year.to_s
      end
    end

    it 'should show day last' do
      date_loop do |date|
        date.to_s(:url).split("-")[2].should == date.day.to_s
      end
    end

    it 'should show 3 letter abbreviations for month names' do
      date_loop do |date|
        date.to_s(:url).split("-")[1].length.should == 3
      end
    end

    it 'should show the full year' do
      date_loop do |date|
        date.to_s(:url).split("-")[0].length.should == 4
      end
    end

    it 'should have the first letter of the month capitalized with the rest lowercased' do
      date_loop do |date|
        date.to_s(:url).split("-")[1].should match(/[A-Z][a-z]+/)
      end
    end
  end


  def date_loop( &b)
    d = 182.days.ago
    while d < 183.days.from_now
      b.call(d.to_date)
      d += 10.day
    end
  end

end

