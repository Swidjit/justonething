class List < ActiveRecord::Base

  belongs_to :user
  has_and_belongs_to_many :users, :uniq => true

  attr_accessible :name

  validates_presence_of :name, :user

end
