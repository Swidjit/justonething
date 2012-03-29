require 'spec_helper'

describe OpenHour do
  describe 'should allow reading and writing of' do
    it 'a day of the week' do
      subject.day_of_week = 'Sunday'
      subject.day_of_week.should == 'Sunday'
    end
    it 'an open time' do
      subject.open_time = '3am'
      subject.open_time.should == '3am'
    end
    it 'a close time' do
      subject.close_time = '6pm'
      subject.close_time.should == '6pm'
    end
  end

  it { should belong_to :user }
end
