class OfferMessage < ActiveRecord::Base
  belongs_to :user
  belongs_to :offer

  validates_presence_of :offer_id, :offer, :user, :text

  attr_accessible :offer, :offer_id, :user, :text
end
