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
      subject.start_time = 2.days.from_now
      subject.start_time.to_s.should == 2.days.from_now.to_s
    end

    it "an end time" do
      subject.end_time = 3.days.from_now
      subject.end_time.to_s.should == 3.days.from_now.to_s
    end
  end
end
