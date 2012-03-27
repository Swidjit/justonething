class OfferMessage < ActiveRecord::Base
  belongs_to :user
  belongs_to :offer

  validates_presence_of :text

  attr_accessible :offer, :text, :user
end
