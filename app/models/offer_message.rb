class OfferMessage < ActiveRecord::Base
  belongs_to :user
  belongs_to :offer

  validates_presence_of :offer, :user, :text

  attr_accessible :offer, :user, :text
end
