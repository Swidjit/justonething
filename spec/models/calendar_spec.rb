require 'spec_helper'

describe Calendar do

  before(:each) {
    
    @user = Factory :user
    
    # add a single event
    event = Factory(:event)
    event.start_datetime = 3.days.from_now + 18.hours
    event.end_datetime = event.start_datetime + 1.hour
    event.expires_on = 1.year.from_now
    event.user = @user
    event.tag_list = 'foo'
    event.save
    
    # add a daily event
    event = Factory(:event)
    event.start_datetime = Time.now + 8.hours
    event.end_datetime = event.start_datetime + 1.hour
    event.expires_on = 4.months.from_now
    event.rule = 'daily'
    event.user = @user
    event.save

    # add a weekly event
    @event = Factory(:event)
    @event.start_datetime = Time.now
    @event.end_datetime = @event.start_datetime + 1.hour
    @event.expires_on = 6.months.from_now
    @event.weekly_day = 3
    @event.rule = 'weekly'
    @event.user = @user
    @event.save
    
  }
  
  describe 'supports loading general events' do
    
    before(:each) {
      @calendar = Calendar.new from: 2.days.from_now, to: 1.week.from_now
    }
    
    it "should have events" do
      @calendar.events.size.should > 0
    end
    
    it "should have user events" do
      @calendar.user = @user
      @calendar.events.size.should > 0
    end
    
    it "should filter tagged events" do
      @calendar.filter = "foo"
      @calendar.events.size.should > 0
    end
    
    
    it "should respect exceptions" do
      @event.cancel_occurrence @event.next_occurrence(1.day.from_now).to_s(:ymd)
      @calendar.events.map(&:id).should_not include @event.id
    end
    
  end


end