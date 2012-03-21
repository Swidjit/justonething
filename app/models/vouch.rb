class Vouch < ActiveRecord::Base

  belongs_to :voucher, :class_name => 'User'
  belongs_to :vouchee, :class_name => 'User'

  validates_uniqueness_of :voucher_id, :scope => :vouchee_id
  validate :user_cannot_vouch_for_self

  def user_cannot_vouch_for_self
    errors.add(:base,'You cannot vouch for yourself') if self.voucher_id == self.vouchee_id
  end

end
