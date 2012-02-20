class Item < ActiveRecord::Base

  belongs_to :user
  has_and_belongs_to_many :tags, :uniq => true

  delegate :display_name, :to => :user, :prefix => true

  attr_accessible :user_id, :user, :title, :description, :expires_in, :tag_list

  attr_accessor :expires_in, :tag_list

  validates_presence_of :title, :description, :user
  validates_presence_of :expires_in, :on => :create

  before_save :convert_expires_in_to_expires_on, :convert_tag_list_to_tags

  private
  def convert_expires_in_to_expires_on
    if expires_in.present? && expires_in.to_i > 0
      self.expires_on = expires_in.to_i.days.from_now.to_date
    end
  end

  def convert_tag_list_to_tags
    self.tags = tag_list.present? ? tag_list.split(',').map{|t| Tag.find_or_create_by_name(t.strip)} : []
  end

end