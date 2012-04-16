class Rsvp < ActiveRecord::Base
  belongs_to :item, :conditions => {type: 'Event'}
  belongs_to :user

  attr_accessible :item_id, :user

  validates_uniqueness_of :user_id, :scope => :item_id

  validates_presence_of :item

end