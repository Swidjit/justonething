class ReminderMailer < ActionMailer::Base
  default from: "swidjit@swidjit.com"
  default :to => "alex@swidjit.com"

  def cancellation(reminder, date)
    user = reminder.user
    item = reminder.item
    @user_name = user.first_name
    @event_name = item.title
    @event_time = "#{item.start_datetime.to_s(:mdy)} @ #{item.start_datetime.to_s(:time)}"
    @url = event_path user.cities.first, item
    mail(:subject => "#{@event_name} Cancelled")
  end

  def reminder(reminder, date)
    user = reminder.user
    item = reminder.item
    @user_name = user.first_name
    @event_name = item.title
    @event_time = item.start_datetime.to_s(:time)
    @url = event_path user.cities.first, item
    mail(:subject => "#{@event_name} Reminder", :to => user.email)
  end


end
