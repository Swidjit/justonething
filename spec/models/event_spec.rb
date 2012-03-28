require 'spec_helper'

describe Event do
  describe "supports reading and writing:" do
    it "a cost" do
      subject.cost = '$40'
      subject.cost.should == '$40'
    end

    it "a location" do
      subject.location = 'Commons'
      subject.location.should == 'Commons'
    end

    it "a start time" do
      start_time = 2.days.from_now
      subject.start_time = start_time
      subject.start_time.to_s.should == start_time.to_s
    end

    it "an end time" do
      subject.end_time = 3.days.from_now
      subject.end_time.to_s.should == 3.days.from_now.to_s
    end

    it "should not allow offers" do
      subject.allows_offers?.should be_false
    end
  end

  describe "#for_week" do
    it "should return an event from today with week 0" do
      event = Factory(:event, :start_datetime => Time.now)
      Event.for_week(0).all.should include event
    end

    it "should return an event from 7 days from now with week 0" do
      event = Factory(:event, :start_datetime => 7.days.from_now)
      Event.for_week(0).all.should include event
    end

    it "should not return an event from 8 days from now with week 0" do
      event = Factory(:event, :start_datetime => 8.days.from_now)
      Event.for_week(0).all.should_not include event
    end

    it "should return an event from 8 days from now with week 1" do
      event = Factory(:event, :start_datetime => 8.days.from_now)
      Event.for_week(1).all.should include event
    end
  end

  before(:all) { @item_class = Event }
  it_should_behave_like 'an item'
end
