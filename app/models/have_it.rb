class HaveIt < Item
#  CONDITIONS = ['New','Gently used','Well loved but working fine','Seen better days','Broken']

  attr_accessible :cost, :condition

#  validate :proper_condition

#  private
#  def proper_condition
#    if self.condition.present?
#      self.errors.add(:condition, 'not included in the list') if CONDITIONS.exclude?(self.condition)
#    end
#  end

end