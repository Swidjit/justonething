class Reminder < ActiveRecord::Base
  belongs_to :item
  belongs_to :user

  attr_accessible :item_id, :user, :date
  
  validates_presence_of :item
  
  scope :for_date, lambda { |date| where ["#{Reminder.table_name}.date IS NULL OR #{Reminder.table_name}.date=?", date] }
  scope :date_and_after, lambda { |date| where ["#{Reminder.table_name}.date>=? OR #{Reminder.table_name}.date IS NULL", date] }
  scope :by_date, lambda { |date| date.present? ? for_date(date) : date_and_after(Date.today) }
  scope :by_item, lambda { |item| where item_id: item.id }
  scope :not_sent_on_date, lambda { |date| where(["#{Reminder.table_name}.sent_on IS NULL OR #{Reminder.table_name}.sent_on < ?", date]) }
  
  def self.send_for_date(date)
    time = date.to_time
    calendar = Calendar.new from: time, to: time
    calendar.events.each { |event| send_for_item event }
  end
  
  def self.send_for_item(item)
    date = item.start_datetime.to_date
    by_item(item).by_date(date).not_sent_on_date(date).each do |reminder|
      reminder.send_reminder_notice date
    end
  end
  
  def self.send_cancellation_notices(item, date=nil)
    by_item(item).by_date(date).each do |reminder|
      reminder.send_cancellation_notice(date) 
    end
  end
  
  # The for date is because the reminder doesn't always have a date - you can subscribe
  # to every occurrence as well as a single recurrence.
  def send_cancellation_notice(for_date)
    return if date.present? and date < Date.today
    ReminderMailer.cancellation(self, for_date).deliver
    mark_as_sent!
  end
  
  def send_reminder_notice(for_date)
    ReminderMailer.reminder(self, for_date).deliver
    mark_as_sent!
  end
  
  def mark_as_sent!
    update_attribute(:sent_on, Date.today)
  end
  
  
end
