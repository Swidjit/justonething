class User < ActiveRecord::Base

  BLACK_LISTED_USER_URLS = %w( communities item_preset_tags bookmarks calendar )

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :encryptable,
         :recoverable, :confirmable, :validatable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :is_thirteen, :last_name, :first_name, :zipcode,
      :display_name, :as => [:default,:devise]

  attr_accessible :about, :websites, :address, :phone, :geo_tag_list, :profile_pic,
    :profile_pic_id, :as => :default

  attr_readonly :display_name

  validate :is_thirteen?, :on => :create
  validates_presence_of :first_name, :last_name, :zipcode
  validates :display_name, :presence => true, :format => { :with => /^[a-zA-Z0-9]+$/, :message => 'can contain only letters and numbers - no spaces or symbols' },
      :exclusion => { :in => BLACK_LISTED_USER_URLS }
  validates_uniqueness_of :display_name, :case_sensitive => false

  before_validation :update_open_hours_if_present

  attr_accessor :is_thirteen, :new_open_hours, :geo_tag_list

  has_many :items
  has_many :lists
  has_and_belongs_to_many :communities, :uniq => true
  has_many :recommendations, :dependent => :destroy
  has_many :rsvps, :dependent => :destroy
  has_many :user_familiarities
  has_many :familiar_users, :through => :user_familiarities, :source => :familiar,
    :conditions => "#{UserFamiliarity.table_name}.familiarness > 0",
    :order => "#{UserFamiliarity.table_name}.familiarness DESC"
  has_many :vouches, :foreign_key => :vouchee_id
  has_many :comments
  has_many :notifications, :foreign_key => :receiver_id

  has_many :bookmarks, :dependent => :destroy
  has_many :bookmarked_items, :through => :bookmarks, :source => :item

  has_and_belongs_to_many :geo_tags, :join_table => :users_tags, :association_foreign_key => :tag_id, :uniq => true, :conditions => "tags.type = 'GeoTag'"

  has_and_belongs_to_many :cities

  # Open Hours
  has_many :open_hours, :dependent => :destroy
  accepts_nested_attributes_for :open_hours

  #Recieved and sent CommunityInvitations
  has_many :rec_comm_invites, :foreign_key => :invitee_id, :class_name => 'CommunityInvitation'
  has_many :sent_comm_invites, :foreign_key => :inviter_id, :class_name => 'CommunityInvitation'

  has_many :delegates_as_delegator, :foreign_key => :delegator_id, :class_name => "Delegate"
  has_many :delegates_as_delegatee, :foreign_key => :delegatee_id, :class_name => "Delegate"
  has_many :delegators, :through => :delegates_as_delegatee
  has_many :delegatees, :through => :delegates_as_delegator

  belongs_to :profile_pic, :class_name => 'Image'
  validates_associated :profile_pic
  accepts_nested_attributes_for :profile_pic

  after_create :add_to_city

  class << self
    def all_by_lower_display_name(display_names)
      self.where('lower(display_name) IN (?)',display_names.map{|name| name.downcase})
    end

    def lower_display_name_like(display_name)
      self.where("lower(display_name) LIKE ?", ["%#{display_name.downcase}%"])
    end

    def by_lower_display_name(display_name)
      self.where('lower(display_name) = ?',[display_name.downcase]).first
    end

    def find_for_facebook_oauth(access_token, signed_in_resource=nil)
      data = access_token.extra.raw_info
      if user = User.where(:email => data.email).first
        user
      else # Create a user with a stub password.
        desired_display_name = data['username'] || (data['first_name'] + data['last_name'])
        username = User.available_display_name( desired_display_name )
        user = User.new({:email => data.email,
            :password => Devise.friendly_token[0,20],
            :first_name => data['first_name'],
            :last_name => data['last_name'],
            :display_name => username,
            :is_thirteen => 1}, :as => :devise ) # Facebook requires the user to be at least 13 as well

        user
      end
    end

    def new_with_session(params, session)
      super
    end
  end

  def can_collect?(item)
    self.collections.any? && self.collections.map(&:id) & (item.collections.where({:user_id => self.id}).map(&:id) << item.id) != self.collections.map(&:id)
  end

  def collections
    self.items.where(:type => 'Collection')
  end

  def delegation_for_user(user)
    @delegation = Delegate.first(:conditions => {:delegator_id => self.id, :delegatee_id => user.id})
  end

  def add_geo_tag(tag_name)
    geo_tag = GeoTag.find_or_initialize_by_name(tag_name)
    unless geo_tags.include?(geo_tag)
      geo_tags << geo_tag
      save
    end
  end

  def rm_geo_tag(tag_name)
    original_geo_tags = geo_tags.dup
    self.geo_tags = []

    geo_tag = GeoTag.find_or_create_by_name(tag_name)
    if original_geo_tags.include?(geo_tag)
      geo_tags = original_geo_tags.reject { |gt| gt == geo_tag }
      save
    end
  end

  private
  def self.available_display_name(desired_display_name)
    similarly_named_users = User.where("display_name LIKE ?", "#{desired_display_name}%").order("display_name")
    taken_names = similarly_named_users.collect(&:display_name) + BLACK_LISTED_USER_URLS

    new_display_name = desired_display_name
    added_number = 0

    while taken_names.include? new_display_name do
      added_number += 1
      new_display_name = "#{desired_display_name}#{added_number}"
    end

    new_display_name
  end

  def add_to_city
    # TODO: base this off of zipcode?
    self.cities << City.first
  end

  def is_thirteen?
    errors.add(:base,'You must be at least 13 years of age to register') if is_thirteen.blank? || is_thirteen.to_i != 1
  end

  def update_open_hours_if_present
    if new_open_hours.present?
      open_hours = []
      new_open_hours.each do |day,oh|
        if oh[:open_time].present? || oh[:close_time].present?
          open_hour = OpenHour.new(oh)
          open_hour.user = self
          open_hours << open_hour
        end
      end
      self.open_hours = open_hours
    end
  end
end
