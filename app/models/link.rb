class Link < Item
  attr_accessible :link
  validates_presence_of :link
end
