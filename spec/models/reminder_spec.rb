require 'spec_helper'

describe Reminder do
  
  it { should belong_to :user }
  it { should belong_to :item }
  
  describe "sends for single events" do
    before(:each) {
      time = Date.today.to_time + 32.hours
      @event = Factory :event, start_datetime: time, end_datetime: (time + 1.hour), user: Factory(:user)
      @user = Factory :user
      @reminder = Factory :reminder, item: @event, user: @user
    }
    
    it 'should send reminder email' do
      start_size = ActionMailer::Base.deliveries.size
      Reminder.send_for_date (Date.today.to_time + 1.day)
      @reminder.reload.sent_on.should_not be_nil
      ActionMailer::Base.deliveries.size.should == start_size + 1
    end
    
    it "should send cancellation notice" do
      start_size = ActionMailer::Base.deliveries.size
      @event.delete
      ActionMailer::Base.deliveries.size.should == start_size + 1
    end
    
  end

  describe "sends for recurring events" do
    before(:each) {
      time = Date.today.to_time + 32.hours
      @event = Factory :event, start_datetime: time, end_datetime: (time + 1.hour), user: Factory(:user)
      @event.weekly_day = 3
      @event.rule = 'weekly'
      @event.save
      @user = Factory :user
      @reminder = Factory :reminder, item: @event, user: @user, date: @event.next_occurrence(2.days.from_now)
    }
    
    it 'should send reminder email' do
      occ = @event.next_occurrence 2.days.from_now
      Reminder.send_for_date occ
      @reminder.reload.sent_on.should_not be_nil
    end
    
    it "should send cancellation notice" do
      @event.cancel_occurrence @event.next_occurrence(2.days.from_now).to_date.to_s
      @reminder.reload.sent_on.should_not be_nil
    end
  end
end
