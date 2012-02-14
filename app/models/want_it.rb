class WantIt < ActiveRecord::Base

  belongs_to :user

  attr_accessor :expires_in

end