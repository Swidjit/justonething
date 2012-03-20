class Recommendation < ActiveRecord::Base

  include ModelReference

  references_users_in :description

  belongs_to :user
  belongs_to :item, :counter_cache => true

  validates_presence_of :user, :item, :description
  validates_uniqueness_of :user_id, :scope => :item_id
  validate :user_cannot_recommend_own_item
  after_save :update_user_familiarity

  attr_accessible :description

  def update_user_familiarity
    UserFamiliarity.update_for(self.user,self.item.user)
  end

  def user_cannot_recommend_own_item
    errors.add(:base, 'You cannot recommend your own item') if item.user == user
  end

end