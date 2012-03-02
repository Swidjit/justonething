class User < ActiveRecord::Base

  BLACK_LISTED_USER_URLS = %w( communities )

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :encryptable,
         :recoverable, :confirmable, :validatable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :is_thirteen, :last_name, :first_name,
      :display_name, :url

  validate :is_thirteen?, :on => :create
  validates_presence_of :first_name, :last_name, :display_name
  validates :url, :uniqueness => true, :presence => true, :format => { :with => /[a-z0-9]+/ },
      :exclusion => { :in => BLACK_LISTED_USER_URLS }

  before_validation :set_default_url, :on => :create
  before_validation :check_updated_url, :on => :update
  before_update :set_user_set_url

  attr_accessor :is_thirteen

  has_many :items
  has_and_belongs_to_many :communities, :uniq => true

  def self.find_for_facebook_oauth(access_token, signed_in_resource=nil)
    data = access_token.extra.raw_info
    if user = User.where(:email => data.email).first
      user
    else # Create a user with a stub password.
      username = data['username'] || (data['first_name'] + data['last_name'])
      user = User.new(:email => data.email,
          :password => Devise.friendly_token[0,20],
          :first_name => data['first_name'],
          :last_name => data['last_name'],
          :display_name => username,
          :is_thirteen => 1) # Facebook requires the user to be at least 13 as well

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

  private
  def check_updated_url
    if self.url_changed? && self.user_set_url
      self.url = self.url_was
    end
  end

  def is_thirteen?
    errors.add(:base,'You must be at least 13 years of age to register') if is_thirteen.blank? || is_thirteen.to_i != 1
  end

  def set_default_url
    if self.url.blank? && self.display_name.present?
      base_url = self.display_name.downcase.gsub(/[^a-z0-9]/,'')
      similarly_named_users = User.where("url LIKE ?", "#{base_url}%").order("url")
      taken_names = similarly_named_users.collect(&:url) + BLACK_LISTED_USER_URLS

      new_url = base_url
      added_number = 0

      while taken_names.include? new_url do
        added_number += 1
        new_url = "#{base_url}#{added_number}"
      end
      self.url = new_url
    end
  end

  def set_user_set_url
    if self.url_changed?
      self.user_set_url = true
    end
  end
end
