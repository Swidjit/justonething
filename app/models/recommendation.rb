class Recommendation < ActiveRecord::Base

  belongs_to :user
  belongs_to :item

  validates_presence_of :user, :item, :description
  validates_uniqueness_of :user_id, :scope => :item_id

  attr_accessible :description

end
