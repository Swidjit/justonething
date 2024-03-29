class Item < ActiveRecord::Base
  self.per_page = 25

  include ModelReference
  include TagConversion

  references_users_in :description, :title

  belongs_to :user
  belongs_to :posted_by_user, :class_name => "User"

  has_many :item_flags, :dependent => :destroy
  has_many :item_flag_users, :through => :item_flags, :source => :user

  has_many :item_visibility_rules, :dependent => :destroy
  has_many :communities, :through => :item_visibility_rules, :source => :visibility,
      :source_type => 'Community', :uniq => true
  has_many :lists, :through => :item_visibility_rules, :source => :visibility,
      :source_type => 'List', :uniq => true
  has_many :collections, :through => :item_visibility_rules, :source => :visibility,
      :source_type => 'Item', :uniq => true
  has_many :cities, :through => :item_visibility_rules, :source => :visibility,
      :source_type => 'City', :uniq => true

  belongs_to :thumbnail, :class_name => 'Image'
  validates_associated :thumbnail
  accepts_nested_attributes_for :thumbnail

  has_many :bookmarks, :dependent => :destroy
  has_many :bookmark_users, :through => :bookmarks, :source => :user

  has_many :comments, :dependent => :destroy
  has_many :offers, :dependent => :destroy
  has_many :notifications, :as => :notifier, :dependent => :delete_all

  has_many :recommendations, :dependent => :destroy
  has_many :recommendation_users, :through => :recommendations, :source => :user

  delegate :display_name, :to => :user, :prefix => true

  attr_protected :user, :posted_by_user
  attr_accessible :title, :description, :has_expiration, :tag_list, :geo_tag_list, :active,
    :expires_on, :community_ids, :list_ids, :thumbnail, :thumbnail_id, :city_ids, :link
  validates :link, :allow_nil => true, :allow_blank => true, :format => { :with => /^(http|https):\/\//, :message => 'Link must begin with http:// or https://' }

  has_and_belongs_to_many :tags, :uniq => true, :conditions => "tags.type IS NULL"
  has_and_belongs_to_many :geo_tags, :join_table => :items_tags, :association_foreign_key => :tag_id, :uniq => true, :conditions => "tags.type = 'GeoTag'"

  attr_accessor :has_expiration

  after_initialize :set_defaults

  validates_presence_of :title, :description, :user
  validates_length_of :title, :maximum => 255
  validates_inclusion_of :active, :in => [true,false]
  validates_inclusion_of :has_expiration, :in => ['0','1']
  validate :user_belongs_to_communities, :user_owns_lists, :posted_by_user_is_delegatee_of_user

  before_validation :handle_has_expiration

  default_scope { order_by_created_at }
  default_scope { where(["#{table_name}.disabled = false"]) }

  scope :order_by_created_at, :order => "#{self.table_name}.created_at DESC"

  scope :active, lambda{ where(["#{table_name}.active = true AND (#{table_name}.expires_on >= ? OR #{table_name}.expires_on IS NULL)", DateTime.now.end_of_day.to_s(:db)]) }
  scope :published, lambda{ where("#{table_name}.active = true")}
  scope :inactive, lambda{ where(["#{table_name}.active = false OR (#{table_name}.expires_on < ?)", DateTime.now.beginning_of_day.to_s(:db)]) }
  scope :deactivated, :conditions => "#{self.table_name}.active = false"
  scope :recommended, where("#{self.table_name}.recommendations_count > 0"
    ).reorder("#{self.table_name}.recommendations_count DESC, #{self.table_name}.created_at DESC")

  scope :having_tag_with_name, lambda { |tag_name| { :joins => :tags, :conditions => ["#{Tag.table_name}.name = ?", tag_name] } }
  scope :having_geo_tags, lambda { |tags| { :joins => :geo_tags, :conditions => ["#{GeoTag.table_name}.name IN (?)", tags.map(&:name)] } }

  scope :of_type, lambda { |type|
    where(["#{table_name}.type = ?", type])
  }

  scope :flagged, :conditions => "EXISTS (SELECT * FROM #{ItemFlag.table_name} WHERE #{ItemFlag.table_name}.item_id = #{table_name}.id)"

  scope :within_community, lambda { |community|
    joins(:communities).where('communities.id'=>community.id)
  }

  def self.access_controlled_for(user, city, ability)
    user ||= User.new
    controlled_scope = joins("LEFT JOIN #{ItemVisibilityRule.table_name} ivr ON #{self.table_name}.id = ivr.item_id " +
        "LEFT JOIN #{City.table_name} ivri ON ivr.visibility_id = ivri.id AND ivr.visibility_type = 'City' AND ivri.id = #{city.id} ")
    if user.persisted?
      controlled_scope = controlled_scope.joins("LEFT JOIN #{List.table_name} ivrl ON ivr.visibility_id = ivrl.id AND ivr.visibility_type = 'List' " +
        "LEFT JOIN lists_users lus ON lus.list_id = ivrl.id AND lus.user_id = #{user.id} " +
        "LEFT JOIN #{Community.table_name} ivrc ON ivr.visibility_id = ivrc.id AND ivr.visibility_type = 'Community' " +
        "LEFT JOIN communities_users cus ON cus.community_id = ivrc.id AND cus.user_id = #{user.id} "
      ).having("( COUNT(ivri.*) > 0 OR COUNT(lus.*) > 0 OR COUNT(cus.*) > 0 ) OR #{self.table_name}.user_id = #{user.id}"
      )
    else
      controlled_scope = controlled_scope.having("COUNT(ivri.*) > 0")
    end

    controlled_scope.active.group(self.column_names.map{ |attr| "#{self.table_name}.#{attr}"}.join(",")).accessible_by(ability)
  end

  def self.count_by_subquery(subquery_arel)
    # Is there a way to say :distinct => false rather than subbing it out?
    subquery = subquery_arel.select('1 as bar').reorder('').to_sql.sub('DISTINCT','')
    result = ActiveRecord::Base.connection.execute("SELECT COUNT(sub.*) as total_count FROM (#{subquery}) sub")
    result.first["total_count"].to_i
  end
  
  def decorator
    (self.class.to_s + "Decorator").constantize
  end
  
  def self.decorate(items=[])
    items.map {|item| item.decorator.decorate item }
  end
  
  def self.decorated
    decorate scoped || []
  end
  
  def to_partial_path
    'items/item'
  end

  def self.classes
    %w{ HaveIt WantIt Event Thought Link Collection }
  end

  def set_defaults
    if !self.persisted?
      self.expires_on = 10.days.from_now.to_s(:db)
    end
    self.has_expiration = self.expires_on.present? ? '1' : '0'
    self.tag_list = self.tags.collect(&:name).join(',')
    self.geo_tag_list = self.geo_tags.collect(&:name).join(',')
  end
  
  def auto_tag_field
    description
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
    return self.item_flag_users.include?(user)
  end

  def disable!
    self.disabled = true
    self.save
  end

  def self.search(query)
    sql = query.split.map do |word|
      %w[title description].map do |column|
        sanitize_sql ["LOWER(#{self.table_name}.#{column}) ~* ?", "\\y#{word.downcase}"]
      end.join(" or ")
    end.join(") and (")
    joins("LEFT JOIN items_tags ON items_tags.item_id = #{self.table_name}.id "+
      "LEFT JOIN #{Tag.table_name} ON #{Tag.table_name}.id = items_tags.tag_id"
      ).where(["(#{sql}) OR #{Tag.table_name}.name IN (?)", query.split])
  end

  # overridden to include slug
  def to_param
    "#{title.to_url}-#{id}"
  end
  
  def processing_through_ui!
    @processing_through_ui = true
  end
  
  def processing_through_ui?
    @processing_through_ui ? true : nil
  end


  private
  def handle_has_expiration
    if has_expiration.present? and has_expiration.to_i == 0
      self.expires_on = nil
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

  def user_owns_lists
    self.user.list_ids.include? self.list_ids
  end
end

