class User < ActiveRecord::Base

  BLACK_LISTED_USER_URLS = %w( communities )

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :encryptable,
         :recoverable, :confirmable, :validatable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :is_thirteen, :last_name, :first_name,
      :display_name, :as => [:default,:devise]

  attr_accessible :user_set_display_name, :as => :devise

  validate :is_thirteen?, :on => :create
  validates_presence_of :first_name, :last_name
  validates :display_name, :presence => true, :format => { :with => /[a-zA-Z0-9]+/ },
      :exclusion => { :in => BLACK_LISTED_USER_URLS }
  validates_uniqueness_of :display_name, :case_sensitive => false

  before_validation :check_updated_display_name, :on => :update
  before_update :set_user_set_display_name

  attr_accessor :is_thirteen

  has_many :items
  has_many :lists
  has_and_belongs_to_many :communities, :uniq => true

  has_many :delegates_as_delegator, :foreign_key => :delegator_id, :class_name => "Delegate"
  has_many :delegates_as_delegatee, :foreign_key => :delegatee_id, :class_name => "Delegate"
  has_many :delegators, :through => :delegates_as_delegatee
  has_many :delegatees, :through => :delegates_as_delegator

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
end
