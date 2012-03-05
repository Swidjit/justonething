class CommunityInvitation < ActiveRecord::Base

  belongs_to :invitee, :class_name => User
  belongs_to :inviter, :class_name => User
  belongs_to :community

  validates_presence_of :invitee, :inviter, :community, :status
  validate :inviter_belongs_to_community

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
end
