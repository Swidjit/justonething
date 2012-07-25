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

  

  describe "#between" do
    it "should return an event from today" do
      event = Factory(:event, start_datetime: 1.day.from_now, end_datetime: 36.hours.from_now)
      Event.between(1.day.from_now.beginning_of_day, 8.days.from_now).should_not be_empty
    end

    it "should return an event from 7 days from now" do
      event = Factory(:event, start_datetime: 7.days.from_now, end_datetime: (7.days.from_now + 1.hour))
      Event.between(Time.now, 7.days.from_now.end_of_day).should_not be_empty
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
      VCR.use_cassette('ical_feed') do
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
      event = @feed.user.items.first
      event.title.should == @feed_event.summary
      event.description.should == @feed_event.description
      event.start_datetime.to_time.to_s.should == @feed_event.dtstart.to_time.to_s
      event.end_datetime.to_time.should.to_s == @feed_event.dtend.to_time.to_s
      event.location.should == @feed_event.location
    end
    
    it "should not import past event" do
      @feed_event.dtstart = 1.day.ago
      @feed_event.dtend = 18.hours.ago
      event = Event.new_from_feed @feed_event, @feed
      event.should be_nil
    end
    
    it "should not import duplicate event" do
      Event.new_from_feed @feed_event, @feed
      count = Event.count
      Event.new_from_feed @feed_event, @feed
      Event.count.should == count
    end
    
    it "should not import events more than a month from now" do
      count = Event.count
      @feed_event.dtstart = 1.month.from_now + 1.day
      @feed_event.dtend = 1.month.from_now + 1.day + 1.hour
      Event.new_from_feed @feed_event, @feed
      Event.count.should == count
    end
  end
  
  describe "#event_recurrences" do
    before(:each) {
      @event = Factory :event
    }
    it "should have recurring rule" do
      @event.rule = 'daily'
      @event.save
      @event.reload.is_recurring?.should == true
    end
    it "should be daily" do
      @event.rule = 'daily'
      @event.save
      @event.reload.is_daily?.should == true
    end
    it "should be weekly" do
      @event.weekly_day = 3
      @event.rule = 'weekly'
      @event.save
      @event.reload.is_weekly?.should == true
    end
    it "should be monthly by week/day" do
      @event.monthly_week = 1
      @event.monthly_day = 2
      @event.rule = 'monthly_week'
      @event.save
      @event.reload.is_monthly_week?.should == true
    end
    it "should be monthly by day of month" do
      @event.monthly_date = 15
      @event.rule = 'monthly_date'
      @event.save
      @event.reload.is_monthly_date?.should == true
      @event.monthly_date.should == 15
    end
    it "should have next occurrence" do
      @event.start_datetime = 1.week.from_now
      @event.end_datetime = 1.week.from_now + 1.hour
      @event.expires_on = 1.year.from_now
      @event.monthly_week = 1
      @event.monthly_day = 2
      @event.rule = 'monthly'
      @event.save
      @event.next_occurrence.should_not be_nil
      # it's important that it has a next occurrence in the future, not going to calculate the next first Tuesday
    end
    it "should return occurrences between two dates" do
      @event.start_datetime = 1.day.from_now
      @event.end_datetime = @event.start_datetime + 1.hour
      @event.rule = 'daily'
      @event.save
      @event.occurrences_between(Time.now.beginning_of_day, 1.week.from_now.end_of_day).size > 0
    end
    it "should update rule expiry when updating event expiry" do
      @event.weekly_day = 3
      @event.rule = 'weekly'
      @event.save
      @event.expires_on = 1.year.from_now
      @event.save
      @event.reload.rule.until_time.to_time.to_s.should == 1.year.from_now.to_time.to_s
    end
  end

  before(:all) { @item_class = Event }
  it_should_behave_like 'an item'
end
