class Notification < ActiveRecord::Base

  validates_presence_of :sender_id, :receiver_id, :notifier_type, :notifier_id

  belongs_to :sender, :class_name => 'User'
  belongs_to :receiver, :class_name => 'User'
  belongs_to :notifier, :polymorphic => true

end
