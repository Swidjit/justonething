class Item < ActiveRecord::Base

  include ModelReference

  references_users_in :description, :title

  belongs_to :user
  belongs_to :posted_by_user, :class_name => "User"

  has_and_belongs_to_many :tags, :uniq => true
  has_many :item_visibility_rules, :dependent => :destroy
  has_many :communities, :through => :item_visibility_rules, :source => :visibility,
      :source_type => 'Community', :uniq => true
  has_many :lists, :through => :item_visibility_rules, :source => :visibility,
      :source_type => 'List', :uniq => true
  has_many :recommendations, :dependent => :destroy
  has_many :recommendation_users, :through => :recommendations, :source => :user
  has_many :comments, :dependent => :destroy
  has_many :offers, :dependent => :destroy
  has_many :notifications, :as => :notifier, :dependent => :delete_all

  delegate :display_name, :to => :user, :prefix => true

  attr_protected :user, :posted_by_user
  attr_accessible :title, :description, :has_expiration, :tag_list, :active, :public,
    :expires_on, :community_ids, :list_ids

  attr_accessor :has_expiration, :tag_list

  after_initialize :set_defaults

  validates_presence_of :title, :description, :user
  validates_inclusion_of :active, :public, :in => [true,false]
  validates_inclusion_of :has_expiration, :in => ['0','1']
  validates_associated :tags, :message => 'can only contain letters, numbers, and hyphens'
  validate :user_belongs_to_communities, :user_owns_lists, :posted_by_user_is_delegatee_of_user

  before_validation :handle_has_expiration, :convert_tag_list_to_tags

  default_scope :order => "#{self.table_name}.created_at DESC", :conditions => "#{table_name}.disabled = false"

  scope :active, :conditions => "#{self.table_name}.active = true"
  scope :deactivated, :conditions => "#{self.table_name}.active = false"
  scope :recommended, where("#{self.table_name}.recommendations_count > 0"
    ).reorder("#{self.table_name}.recommendations_count DESC, #{self.table_name}.created_at DESC")

  scope :having_tag_with_name, lambda { |tag_name| { :joins => :tags, :conditions => ["#{Tag.table_name}.name = ?", tag_name] } }

  scope :flagged, :conditions => "EXISTS (SELECT * FROM #{ItemFlag.table_name} WHERE #{ItemFlag.table_name}.item_id = #{table_name}.id)"

  def self.access_controlled_for(user,ability)
    user ||= User.new
    controlled_scope = joins("LEFT JOIN #{ItemVisibilityRule.table_name} ivr ON #{self.table_name}.id = ivr.item_id")
    if user.persisted?
      controlled_scope = controlled_scope.joins("LEFT JOIN #{List.table_name} ivrl ON ivr.visibility_id = ivrl.id AND ivr.visibility_type = 'List' " +
        "LEFT JOIN lists_users lus ON lus.list_id = ivrl.id AND lus.user_id = #{user.id} " +
        "LEFT JOIN #{Community.table_name} ivrc ON ivr.visibility_id = ivrc.id AND ivr.visibility_type = 'Community' " +
        "LEFT JOIN communities_users cus ON cus.community_id = ivrc.id AND cus.user_id = #{user.id} "
      ).having("( COUNT(ivr.*) = 0 OR COUNT(lus.*) > 0 OR COUNT(cus.*) > 0 ) OR #{self.table_name}.user_id = #{user.id}"
      )
    else
      controlled_scope = controlled_scope.having("COUNT(ivr.*) = 0")
    end

    controlled_scope.group(self.column_names.map{ |attr| "#{self.table_name}.#{attr}"}.join(",")).accessible_by(ability)
  end

  def set_defaults
    if !self.persisted?
      self.expires_on = 10.days.from_now
    end
    self.has_expiration = self.expires_on.present? ? '1' : '0'
  end

  def allows_offers?
    return self.kind_of?(HaveIt) || self.kind_of?(WantIt)
  end

  def has_offer_from?(user)
    return self.offers.map(&:user).include?(user)
  end

  def offer_from(user)
    return Offer.find(:first, :conditions => { :user_id => user.id, :item_id => self.id })
  end

  def flag!(user)
    ItemFlag.create(:item => self, :user => user)
  end

  def flagged_by_user?(user)
    return ItemFlag.find_by_item_id_and_user_id(id, user.id).present?
  end

  def disable!
    self.disabled = true
    self.save
  end

  def self.search(query)
    sql = query.split.map do |word|
      %w[title description].map do |column|
        sanitize_sql ["LOWER(#{self.table_name}.#{column}) LIKE ?", "%#{word.downcase}%"]
      end.join(" or ")
    end.join(") and (")
    joins("LEFT JOIN items_tags ON items_tags.item_id = #{self.table_name}.id "+
      "LEFT JOIN #{Tag.table_name} ON #{Tag.table_name}.id = items_tags.tag_id"
      ).where(["(#{sql}) OR #{Tag.table_name}.name IN (?)", query.split])
  end

  private
  def handle_has_expiration
    if has_expiration.to_i == 0
      self.expires_on = nil
    end
  end

  def convert_tag_list_to_tags
    self.tags = []
    temp_tags = []
    tag_list.split(',').map{|t| temp_tags << Tag.find_or_initialize_by_name(t.strip.downcase)} if tag_list.present?
    self.description.scan(/#([a-zA-Z0-9-]+)/) do |tag|
      temp_tags << Tag.find_or_initialize_by_name(tag[0].strip.downcase)
    end
    self.tags = temp_tags.uniq
  end

  def user_belongs_to_communities
    self.user.community_ids.include? self.community_ids
  end

  def posted_by_user_is_delegatee_of_user
    if posted_by_user.present?
      self.errors.add(:user, "cannot post as") unless posted_by_user.delegators.include? self.user
    end
  end

  def user_owns_lists
    self.user.list_ids.include? self.list_ids
  end
end

