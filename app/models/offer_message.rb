class OfferMessage < ActiveRecord::Base
  belongs_to :user
  belongs_to :offer
  has_many :notifications, :as => :notifier, :dependent => :delete_all

  validates_presence_of :offer_id, :offer, :user, :text

  attr_accessible :offer, :offer_id, :user, :text

  after_create :notify_appropriate_user

private
  def notify_appropriate_user
    # if this is the first message then Offer will handle the notification
    if self.offer.messages.count > 1
      notification = Notification.new
      notification.notifier = self

      # If this is the user that sent the offer then notify item owner
      if self.offer.user_id == self.user_id
        notification.sender = self.user
        notification.receiver = self.offer.item.user
      else
        notification.sender = self.user
        notification.receiver = self.offer.user
      end

      notification.save
    end
  end
end
