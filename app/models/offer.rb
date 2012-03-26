class Offer < ActiveRecord::Base
  belongs_to :user
  belongs_to :item
  has_many :messages, :class_name => "OfferMessage", :dependent => :destroy

  validates :user_id, :exclusion => { :in => lambda { |offer|
    [Item.find(offer.item_id).user_id]
  }, :message => "You cannot create an offer on your own item." }
end
