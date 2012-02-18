class HaveIt < Item
  attr_accessible :cost, :condition

  validates_presence_of :cost, :condition
end