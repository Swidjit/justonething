class Comment < ActiveRecord::Base

  attr_accessible :text

  validates_presence_of :text, :item, :user

  has_ancestry

  belongs_to :item
  belongs_to :user

end
