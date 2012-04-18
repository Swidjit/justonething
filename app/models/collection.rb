class Collection < Item
  has_many :visibility_rules, :as => :visibility, :class_name => 'ItemVisibilityRule', :dependent => :destroy
  has_many :items, :through => :visibility_rules, :uniq => true
end
