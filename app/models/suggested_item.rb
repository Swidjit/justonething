class SuggestedItem < ActiveRecord::Base
  belongs_to :user
  belongs_to :item
  has_many :suggested_users, :dependent => :destroy
  has_many :users, :through => :suggested_users, :uniq => true
  #has_many :item_visibility_rules, :as => :visibility, :dependent => :destroy
  before_destroy :delete_all_message_notifications
  after_create :notify_suggestion_recipient

  #has_many :messages, :class_name => "OfferMessage", :order => "#{OfferMessage.table_name}.created_at ASC", :dependent => :delete_all
  has_many :notifications, :as => :notifier, :dependent => :delete_all
  #has_many :message_notifications, :through => :messages, :source => :notifications

  attr_accessible :item_id, :user, :suggested_user_id
  attr_accessor :suggestion_recipient

  validates_presence_of :item_id, :user, :suggested_user_id
  #validates_uniqueness_of :name, :scope => :user_id
  
  private
  
  def notify_suggestion_recipient
    notification = Notification.new
    notification.notifier = self
    notification.sender = User.find(self.user.id)
    notification.receiver = User.find(self.suggested_user_id)
    notification.save
  end
  
end
