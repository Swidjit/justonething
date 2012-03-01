class HaveIt < Item
  CONDITIONS = ['New','Gently used','Well loved but working fine','Seen better days','Broken']

  attr_accessible :cost, :condition

  validates_inclusion_of :condition, :in => CONDITIONS

end