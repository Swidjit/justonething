class Offer < ActiveRecord::Base
  belongs_to :user
  belongs_to :item
  has_many :messages, :class_name => "OfferMessage", :order => "#{OfferMessage.table_name}.created_at ASC", :dependent => :delete_all
  has_many :notifications, :as => :notifier, :dependent => :delete_all

  attr_accessible :user, :item_id

  validates_uniqueness_of :item_id, :scope => :user_id, :message => "You can only have one offer per item."

  validates :user_id, :exclusion => { :in => lambda { |offer|
    [Item.find(offer.item_id).user_id]
  }, :message => "You cannot create an offer on your own item." }

  validate :item_type_is_allowed

  after_create :send_notification_email, :notify_item_owner

  scope :for_user, lambda { |user| { :joins => :item, :conditions => ["#{Item.table_name}.user_id = ?", user.id] } }

private
  def item_type_is_allowed
    errors.add(:item, "type not allowed") unless item.allows_offers?
  end

  def notify_item_owner
    notification = Notification.new
    notification.notifier = self
    notification.sender = self.user
    notification.receiver = self.item.user
    notification.save
  end

  def send_notification_email
    OfferMailer.new_offer_email(self).deliver
  end
end
