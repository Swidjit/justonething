class CustomFeedElement < ActiveRecord::Base
  belongs_to :custom_feed

  #validates_uniqueness_of :user_id, :scope => :list_id

  attr_accessible :custom_feed, :custom_feed_id
  
  attr_accessor :custom_feed_user_id

end
