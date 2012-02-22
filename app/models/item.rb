class Item < ActiveRecord::Base

  belongs_to :user
  has_and_belongs_to_many :tags, :uniq => true

  delegate :display_name, :to => :user, :prefix => true

  attr_accessible :user_id, :user, :title, :description, :expires_in, :tag_list, :active

  attr_accessor :expires_in, :tag_list

  validates_presence_of :title, :description, :user
  validates_presence_of :expires_in, :on => :create
  validates_inclusion_of :active, :public, :in => [true,false]

  before_save :convert_expires_in_to_expires_on, :convert_tag_list_to_tags

  default_scope :order => "#{self.table_name}.created_at DESC"

  scope :active, :conditions => "#{self.table_name}.active = true"

  private
  def convert_expires_in_to_expires_on
    self.expires_on = expires_in.to_i.days.from_now.to_date if expires_in.present? && expires_in.to_i > 0
    self.expires_on = nil if expires_in.present? && expires_in.to_i == 0
  end

  def convert_tag_list_to_tags
    self.tags = tag_list.present? ? tag_list.split(',').map{|t| Tag.find_or_create_by_name(t.strip)} : []
  end

end