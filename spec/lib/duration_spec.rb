require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Duration do

  it 'should be accessible via Integer#to_duration' do
    100.to_duration.class.should == Duration
  end

  it 'should return an empty string for a negative duration' do
    -10.to_duration.to_s.should be_empty
  end

  it 'should never show more than two units' do
    (1.day + 1.hour + 1.second).to_duration.to_s.split.length.should == 4
  end

  it 'should only show seconds from 0 seconds to 59 seconds' do
    duration_loop(:from => 0.seconds, :to => 59.seconds, :inc => 1.second) do |t|
      t.to_s.should_not match(/day/)
      t.to_s.should_not match(/hr/)
      t.to_s.should_not match(/min/)
      t.to_s.should match(/sec$/)
    end
  end

  it 'should show minutes and seconds from 1 minute and 0 seconds to 9 minutes and 59 seconds' do
    duration_loop(:from => (1.minute + 0.seconds), :to => (9.minutes + 59.seconds), :inc => 5.seconds) do |t|
      t.to_s.should_not match(/day/)
      t.to_s.should_not match(/hr/)
      t.to_s.should     match(/min/)
      t.to_s.should     match(/sec$/)
    end
  end

  it 'should show minutes only from 10 minutes to just before 60 minutes' do
    duration_loop(:from => 10.minutes, :to => (59.minutes - 1.second), :inc => 50.seconds) do |t|
      t.to_s.should_not match(/day/)
      t.to_s.should_not match(/hr/)
      t.to_s.should     match(/min$/)
      t.to_s.should_not match(/sec/)
    end
  end

  it 'should show hours and minutes from 1 hour and 0 minutes to just before 24 hours' do
    duration_loop(:from => (1.hour + 0.minutes), :to => (24.hours - 1.seconds), :inc => 50.minutes) do |t|
      t.to_s.should_not match(/day/)
      t.to_s.should     match(/hr/)
      t.to_s.should     match(/min$/)
      t.to_s.should_not match(/sec/)
    end
  end

  it 'should show days and hours from 1 day to just before 7 days' do
    duration_loop(:from => 1.day, :to => (7.days - 1.second), :inc => 22.hours) do |t|
      t.to_s.should     match(/day/)
      t.to_s.should     match(/hr$/)
      t.to_s.should_not match(/min/)
      t.to_s.should_not match(/sec/)
    end
  end

  it 'should show days only for anything greater than 7 days' do
    duration_loop(:from => 7.days, :to => 1.year.to_i, :inc => 30.days) do |t|
      t.to_s.should     match(/day$/)
      t.to_s.should_not match(/hr/)
      t.to_s.should_not match(/min/)
      t.to_s.should_not match(/sec/)
    end
  end


  def duration_loop(opts, &b)
    time = opts[:from]
    while time < opts[:to]
      b.call(time.to_duration)
      time += opts[:inc]
    end
    b.call(opts[:to].to_duration) # Ensure call to the last time
  end

end

