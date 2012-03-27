class Offer < ActiveRecord::Base
  belongs_to :user
  belongs_to :item
  has_many :messages, :class_name => "OfferMessage", :dependent => :destroy, :order => "#{OfferMessage.table_name}.created_at ASC"

  attr_accessible :user, :item_id

  validates_uniqueness_of :item_id, :scope => :user_id, :message => "You can only have one offer per item."

  validates :user_id, :exclusion => { :in => lambda { |offer|
    [Item.find(offer.item_id).user_id]
  }, :message => "You cannot create an offer on your own item." }

  validate :item_type_is_allowed

private

  def item_type_is_allowed
    errors.add(:item, "type not allowed") unless item.allows_offers?
  end
end
