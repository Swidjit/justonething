class Item < ActiveRecord::Base
  belongs_to :user
  belongs_to :posted_by_user, :class_name => "User"

  has_and_belongs_to_many :tags, :uniq => true
  has_many :item_visibility_rules, :dependent => :destroy
  has_many :communities, :through => :item_visibility_rules, :source => :visibility,
      :source_type => 'Community', :uniq => true

  delegate :display_name, :to => :user, :prefix => true

  attr_protected :user, :posted_by_user
  attr_accessible :title, :description, :has_expiration, :tag_list, :active, :public, :expires_on, :community_ids

  attr_accessor :has_expiration, :tag_list

  after_initialize :set_defaults

  validates_presence_of :title, :description, :user
  validates_inclusion_of :active, :public, :in => [true,false]
  validates_inclusion_of :has_expiration, :in => ['0','1']
  validates_associated :tags, :message => 'can only contain letters, numbers, and hyphens'
  validate :user_belongs_to_communities, :posted_by_user_is_delegatee_of_user

  before_validation :handle_has_expiration, :convert_tag_list_to_tags

  default_scope :order => "#{self.table_name}.created_at DESC"

  scope :active, :conditions => "#{self.table_name}.active = true"
  scope :deactivated, :conditions => "#{self.table_name}.active = false"

  def set_defaults
    if !self.persisted?
      self.expires_on = 10.days.from_now
    end
    self.has_expiration = self.expires_on.present? ? '1' : '0'
  end

  private
  def handle_has_expiration
    if has_expiration.to_i == 0
      self.expires_on = nil
    end
  end

  def convert_tag_list_to_tags
    self.tags = []
    tag_list.split(',').map{|t| self.tags << Tag.find_or_initialize_by_name(t.strip.downcase)} if tag_list.present?
    self.description.scan(/#([a-zA-Z0-9-]+)/) do |tag|
      self.tags << Tag.find_or_initialize_by_name(tag[0].strip.downcase)
    end
  end

  def user_belongs_to_communities
    self.user.community_ids.include? self.community_ids
  end

  def posted_by_user_is_delegatee_of_user
    if posted_by_user.present?
      self.errors.add(:user, "cannot post as") unless posted_by_user.delegators.include? self.user
    end
  end
end
