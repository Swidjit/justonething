class CommunityInvitation < ActiveRecord::Base

  belongs_to :invitee, :class_name => User
  belongs_to :inviter, :class_name => User
  belongs_to :community
  has_many :notifications, :as => :notifier, :dependent => :delete_all

  attr_accessible :community_id, :inviter_id, :invitee_id

  validates_presence_of :invitee, :inviter, :community, :status
  validate :inviter_belongs_to_community

  after_create :notify_recipient

  scope :pending, :conditions => { :status => 'P' }

  def accept!
    self.status = 'A'
    self.invitee.communities << self.community
    self.save
  end

  def decline!
    self.status = 'D'
    self.save
  end

protected

  def inviter_belongs_to_community
    unless self.inviter.present? && self.inviter.communities.include?(self.community)
      errors.add(:base,'You must belong to the community to invite others to it.')
    end
  end

  def notify_recipient
    notification = Notification.new
    notification.notifier = self
    notification.sender = self.inviter
    notification.receiver = self.invitee
    notification.save
  end
end
