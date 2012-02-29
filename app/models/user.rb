class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :encryptable,
         :recoverable, :confirmable, :validatable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :is_thirteen, :last_name, :first_name,
      :display_name, :url

  validate :is_thirteen?, :on => :create
  validates_presence_of :first_name, :last_name, :display_name, :url
  validates_uniqueness_of :url

  attr_accessor :is_thirteen

  has_many :items

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
  def is_thirteen?
    errors.add(:base,'You must be at least 13 years of age to register') if is_thirteen.blank? || is_thirteen.to_i != 1
  end
end
