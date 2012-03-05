class Link < Item
  attr_accessible :link
  validates :link, :presence => true, :format => { :with => /^(http|https):\/\//,
      :message => 'Link must begin with http:// or https://' }
end
