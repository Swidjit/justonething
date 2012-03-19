class Bookmark < ActiveRecord::Base
  belongs_to :item
  belongs_to :user

  attr_accessible :item_id, :user

  validates_uniqueness_of :user_id, :scope => :item_id

  scope :for_user, lambda { |user| {
    :conditions => { :user_id => user.id }
  } }
end
