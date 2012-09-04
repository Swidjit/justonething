class Offer < ActiveRecord::Base
  before_destroy :delete_all_message_notifications
  after_create :notify_item_owner

  belongs_to :user
  belongs_to :item
  has_many :messages, :class_name => "OfferMessage", :order => "#{OfferMessage.table_name}.created_at ASC", :dependent => :delete_all
  has_many :notifications, :as => :notifier, :dependent => :delete_all
  has_many :message_notifications, :through => :messages, :source => :notifications

  attr_accessible :user, :item_id

  validates_uniqueness_of :item_id, :scope => :user_id, :message => "You can only have one message thread per item."

  validates :user_id, :exclusion => { :in => lambda { |offer|
    [Item.find(offer.item_id).user_id]
  }, :message => "You cannot message yourself about your own item." }

  #validate :item_type_is_allowed

  scope :for_user, lambda { |user| { :joins => :item, :conditions => ["#{Item.table_name}.user_id = ?", user.id] } }

  private
  def delete_all_message_notifications
    Notification.delete_all(:id => self.message_notifications.collect(&:id))
  end

  def item_type_is_allowed
    #errors.add(:item, "type not allowed") unless item.allows_offers?
    true
  end

  def notify_item_owner
    notification = Notification.new
    notification.notifier = self
    notification.sender = self.user
    notification.receiver = self.item.user
    notification.save
  end
end
