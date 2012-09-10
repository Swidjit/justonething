class CustomFeed < ActiveRecord::Base
  belongs_to :user
  
  has_many :elements, :class_name => "CustomFeedElement"
  has_many :custom_feed_subscriptions, :dependent => :destroy
  has_many :users, :through => :custom_feed_subscriptions, :uniq => true
  #has_many :item_visibility_rules, :as => :visibility, :dependent => :destroy

  attr_accessible :name, :description
  
  #validates_presence_of :name, :user
  #validates_uniqueness_of :name, :scope => :user_id  
  
end
