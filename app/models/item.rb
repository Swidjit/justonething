class Item < ActiveRecord::Base

  belongs_to :user

  attr_accessible :user_id, :user, :title, :description, :expires_in

  attr_accessor :expires_in

end