module Event::Reminders
  extend ActiveSupport::Concern
  included do
    
    has_many :reminders, foreign_key: :item_id, dependent: :destroy
  
  end
  
  def delete
    send_cancellation_notices and destroy
  end

  def has_reminder_for?(user)
    reminder_for_user(user).present?
  end
  
  def reminder_for_user(user)
    @reminders_for_user ||= user.reminders.by_item(self).by_date(start_datetime).first
  end
  
  private
  
  def send_cancellation_notices
    Reminder.send_cancellation_notices self
    true
  end

end