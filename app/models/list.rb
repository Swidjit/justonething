class List < ActiveRecord::Base

  belongs_to :user
  has_many :lists_users, :dependent => :destroy
  has_many :users, :through => :lists_users, :uniq => true
  has_many :item_visibility_rules, :as => :visibility, :dependent => :destroy

  attr_accessible :name

  validates_presence_of :name, :user
  validates_uniqueness_of :name, :scope => :user_id

  def users= (*users)
    # Workaround to force callbacks on lists_users
    # TODO: Only remove removed users and only add new users (Prevent removing and then readding)
    self.lists_users.clear
    users.each{|usr| self.users << usr}
  end

end
