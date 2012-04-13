class Rsvp < ActiveRecord::Base
  belongs_to :item
  belongs_to :user

  attr_accessible :item_id, :user

  validates_uniqueness_of :user_id, :scope => :item_id

  after_save :update_user_familiarity

  scope :for_user, lambda { |user| {
    :conditions => { :user_id => user.id }
  } }

  def update_user_familiarity
    UserFamiliarity.update_for(self.user,self.item.user)
  end
end
