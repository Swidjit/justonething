require 'spec_helper'

describe Rsvp do
  describe "an rsvp" do
    it "should only allow user to rsvp for an event once" do
      bookmark = Factory(:rsvp)
      Factory.build(:rsvp, :item => bookmark.item, :user => bookmark.user).should be_invalid
    end
  end

  describe "retrieving rsvps" do
    it "should be filterable by user" do
      r1 = Factory(:rsvp)
      r2 = Factory(:rsvp)

      Rsvp.for_user(r1.user).should == [r1]
      Rsvp.for_user(r2.user).should == [r2]
    end
  end
end
