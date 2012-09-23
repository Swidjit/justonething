class UserPage < ActiveRecord::Base
  belongs_to :user
  attr_accessible :name, :body
end
