class Delegate < ActiveRecord::Base
  belongs_to :delegator, :class_name => "User"
  belongs_to :delegatee, :class_name => "User"
  has_many :notifications, :as => :notifier, :dependent => :delete_all

  validates_uniqueness_of :delegatee_id, :scope => :delegator_id
  validate :delegator_is_not_delegatee

  after_create :notify_delegatee

private

  def delegator_is_not_delegatee
    errors.add(:delegatee, "Cannot delegate to oneself.") if delegator == delegatee
  end

  def notify_delegatee
    notification = Notification.new
    notification.notifier = self
    notification.sender = self.delegator
    notification.receiver = self.delegatee
    notification.save
  end
end
