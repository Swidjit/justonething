class Delegate < ActiveRecord::Base
  belongs_to :delegator, :class_name => "User"
  belongs_to :delegatee, :class_name => "User"

  validates_uniqueness_of :delegatee_id, :scope => :delegator_id
end
