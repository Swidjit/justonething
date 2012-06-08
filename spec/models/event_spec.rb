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

  it "cannot create an event in the past" do
    event = Factory.build(:event, :start_datetime => (Time.now - 1))
    event.should_not be_valid
    event.should have(1).error_on(:start_date)
  end

  describe "#for_week" do
    it "should return an event from today with week 0" do
      event = Factory(:event, :start_datetime => 1.days.from_now)
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

  describe "#owned_or_bookmarked_by_or_rsvp_to" do
    before(:each) { @item = Factory(:event) }

    it "should return items owned by a user" do
      Event.owned_or_bookmarked_by_or_rsvp_to(@item.user).count.should == 1
    end

    it "should return items bookmarked by a user" do
      bookmark = Factory(:bookmark, :item => @item)
      Event.owned_or_bookmarked_by_or_rsvp_to(bookmark.user).count.should == 1
    end

    it "should only return one instance for an item bookmarked by its owner" do
      bookmark = Factory(:bookmark, :item => @item, :user => @item.user)
      Event.owned_or_bookmarked_by_or_rsvp_to(bookmark.user).count.should == 1
    end

    it "should return items rsvp'd to by a user" do
      rsvp = Factory(:rsvp, :item => @item)
      Event.owned_or_bookmarked_by_or_rsvp_to(rsvp.user).count.should == 1
    end
  end
  
  describe '#importing_from_ical_feed' do
    before(:each) {
      VCR.use_cassette('ical_feed', erb: true, allow_playback_repeats: true) do
        @feed = Factory :feed
      end
      @feed_event = Icalendar::Event.new
      @feed_event.summary = 'Pancake Breakfast'
      @feed_event.description = 'Come join us at the Varna Community Center for pancakes.'
      @feed_event.dtstart = 2.days.from_now
      @feed_event.dtend = 2.days.from_now + 3.hours
      @feed_event.location = 'Varna Community Center'
    }
    it "should import future event" do
      Event.new_from_feed @feed_event, @feed
      
      event = @feed.user.items.last
      event.title.should == @feed_event.summary
      event.description.should == @feed_event.description
      event.start_datetime.to_time.should == @feed_event.dtstart.to_time
      event.end_datetime.to_time.should == @feed_event.dtend.to_time
      event.location.should == @feed_event.location
    end
    
    it "should not import past event" do
      @feed_event.dtstart = 1.day.ago
      @feed_event.dtend = 18.hours.ago
      Event.new_from_feed @feed_event, @feed
      @feed.user.items.count.should == 0
    end
    
    it "should not import duplicate event" do
      Event.new_from_feed @feed_event, @feed
      Event.new_from_feed @feed_event, @feed
      @feed.user.items.count.should == 1
    end
    
    it "should not import events more than a month from now" do
      @feed_event.dtstart = 1.month.from_now + 1.day
      @feed_event.dtend = 1.month.from_now + 1.day + 1.hour
      Event.new_from_feed @feed_event, @feed
      @feed.user.items.count.should == 0
      
    end
  end

  before(:all) { @item_class = Event }
  it_should_behave_like 'an item'
end
