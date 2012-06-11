class OfferMessage < ActiveRecord::Base
  belongs_to :user
  belongs_to :offer
  has_many :notifications, :as => :notifier, :dependent => :delete_all

  validates_presence_of :offer_id, :offer, :user, :text

  attr_accessible :offer, :offer_id, :user, :text

  after_create :notify_appropriate_user
  after_create :send_email

private
  def notify_appropriate_user
    # if this is the first message then Offer will handle the notification
    if self.offer.messages.count > 1
      notification = Notification.new
      notification.notifier = self

      notification.sender = self.user
      notification.receiver = notification_recipient

      notification.save
    end
  end

  def send_email
    OfferMailer.new_offer_email(self.offer, notification_recipient).deliver
  end

  def notification_recipient
    return (self.offer.user_id == self.user_id) ? self.offer.item.user : self.offer.user
  end
end
