class OfferMessage < ActiveRecord::Base
  belongs_to :offer

  validates_presence_of :text
end
