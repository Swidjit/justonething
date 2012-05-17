class Comment < ActiveRecord::Base

  include ModelReference

  references_users_in :text

  attr_accessible :text, :parent_id

  validates_presence_of :text, :item, :user

  has_ancestry

  belongs_to :item
  belongs_to :user
  has_many :notifications, :as => :notifier, :dependent => :delete_all

  after_save :update_user_familiarity
  after_destroy :update_user_familiarity

  after_create :notify_appropriate_user

  def update_user_familiarity
    UserFamiliarity.update_for(self.user,self.item.user)
    UserFamiliarity.update_for(self.item.user,self.user)
  end

private
  def notify_appropriate_user
    notification = Notification.new
    notification.notifier = self
    notification.sender = self.user
    if self.is_root?
      notification.receiver = self.item.user
      CommentMailer.new_comment_email(self.item, self.item.user, self.user, self.text).deliver
    else
      notification.receiver = self.parent.user
      CommentMailer.new_comment_reply_email(self.item, self.parent.user, self.user, self.text).deliver
    end
    notification.save
  end
end
