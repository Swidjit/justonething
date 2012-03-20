class ListsUser < ActiveRecord::Base
  belongs_to :list
  belongs_to :user

  validates_uniqueness_of :user_id, :scope => :list_id

  attr_accessible :list, :user, :list_id, :user_id

  attr_accessor :list_user_id

  after_validation :store_list_user_id
  before_destroy :store_list_user_id
  after_destroy :update_familiarity
  after_save :update_familiarity

  def store_list_user_id
    self.list_user_id = self.list.user_id
  end

  def update_familiarity
    UserFamiliarity.update_for(User.find(self.list_user_id), User.find(self.user_id))
  end

end
