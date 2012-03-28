class Comment < ActiveRecord::Base

  include ModelReference

  references_users_in :text

  attr_accessible :text, :parent_id

  validates_presence_of :text, :item, :user

  has_ancestry

  belongs_to :item
  belongs_to :user

  after_save :update_user_familiarity
  after_destroy :update_user_familiarity

  after_create :notify_item_owner

  def update_user_familiarity
    UserFamiliarity.update_for(self.user,self.item.user)
    UserFamiliarity.update_for(self.item.user,self.user)
  end

private
  def notify_item_owner
    notification = Notification.new
    notification.notifier = self
    notification.sender = self.user
    notification.receiver = self.item.user
    notification.save
  end
end
