class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :encryptable,
         :recoverable, :confirmable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :is_thirteen

  validate :is_thirteen?, :on => :create

  attr_accessor :is_thirteen


  private
  def is_thirteen?
    errors.add(:base,'You must be at least 13 years of age to register') if is_thirteen.blank? || is_thirteen.to_i != 1
  end
end
