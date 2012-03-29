require 'spec_helper'

describe DateTimeDecorator do
  it "#event_start_time" do
    DateTimeDecorator.new(DateTime.new(2012, 01, 01, 01, 01)).event_start_time.should == "Jan. 01, 2012 @ 01:01 AM"
  end
end
