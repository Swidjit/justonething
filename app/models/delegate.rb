class Delegate < ActiveRecord::Base
  belongs_to :delegator, :class_name => "User"
  belongs_to :delegatee, :class_name => "User"

  validates_uniqueness_of :delegatee_id, :scope => :delegator_id
  validate :delegator_is_not_delegatee

private

  def delegator_is_not_delegatee
    errors.add(:delegatee, "Cannot delegate to oneself.") if delegator == delegatee
  end
end
