class User < ActiveRecord::Base

  BLACK_LISTED_USER_URLS = %w( communities item_preset_tags bookmarks calendar )

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :encryptable,
         :recoverable, :confirmable, :validatable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :is_thirteen, :last_name, :first_name, :zipcode,
      :display_name, :as => [:default,:devise]

  attr_accessible :about, :websites, :address, :phone, :as => :default
  attr_accessible :user_set_display_name, :as => :devise

  validate :is_thirteen?, :on => :create
  validates_presence_of :first_name, :last_name, :zipcode
  validates :display_name, :presence => true, :format => { :with => /[a-zA-Z0-9]+/ },
      :exclusion => { :in => BLACK_LISTED_USER_URLS }
  validates_uniqueness_of :display_name, :case_sensitive => false

  before_validation :check_updated_display_name, :on => :update
  before_validation :update_open_hours_if_present
  before_update :set_user_set_display_name

  attr_accessor :is_thirteen, :new_open_hours

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

  def self.all_by_lower_display_name(display_names)
    self.where('lower(display_name) IN (?)',display_names.map{|name| name.downcase})
  end

  def self.lower_display_name_like(display_name)
    self.where("lower(display_name) LIKE ?", ["%#{display_name.downcase}%"])
  end

  def self.by_lower_display_name(display_name)
    self.where('lower(display_name) = ?',[display_name.downcase]).first
  end

  def self.find_for_facebook_oauth(access_token, signed_in_resource=nil)
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
          :user_set_display_name => false,
          :is_thirteen => 1}, :as => :devise ) # Facebook requires the user to be at least 13 as well

      # Facebook requires a valid email before allowing the user to add Apps like Swidjit
      user.skip_confirmation!
      user.save
      user
    end
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"]
      end
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

  private
  def check_updated_display_name
    if self.display_name_changed? && self.user_set_display_name
      self.display_name = self.display_name_was
    end
  end

  def is_thirteen?
    errors.add(:base,'You must be at least 13 years of age to register') if is_thirteen.blank? || is_thirteen.to_i != 1
  end

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

  def set_user_set_display_name
    if self.display_name_changed?
      self.user_set_display_name = true
    end
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