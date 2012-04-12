class ItemFlag < ActiveRecord::Base
  belongs_to :item
  belongs_to :user

  attr_accessible :user, :item

  validates_uniqueness_of :user_id, :scope => :item_id
end
