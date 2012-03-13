class Community < ActiveRecord::Base

  validates_presence_of :name, :user

  belongs_to :user
  has_and_belongs_to_many :users, :uniq => true
  has_many :item_visibility_rules, :as => :visibility, :dependent => :destroy
  has_many :items, :through => :item_visibility_rules, :uniq => true

  attr_accessible :name

  before_create :add_creator_as_user

private
  def add_creator_as_user
    self.users << self.user
  end

end