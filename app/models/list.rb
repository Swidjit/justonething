class List < ActiveRecord::Base

  belongs_to :user
  has_and_belongs_to_many :users

  attr_accessible :name

  validates_presence_of :name, :user

end
