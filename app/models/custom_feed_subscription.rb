class CustomFeedSubscription < ActiveRecord::Base
  belongs_to :custom_feed
  belongs_to :user

  #validates_uniqueness_of :user_id, :scope => :list_id

  attr_accessible :custom_feed, :custom_feed_id, :user, :user_id

  attr_accessor :custom_feed_user_id

  
  #validates_presence_of :user, :custom_feed_id, :frequency
  #validates_numericality_of :frequence, :custom_feed_id
  

end
