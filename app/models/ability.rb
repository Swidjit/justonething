class Ability
  include CanCan::Ability

  ITEMS = [Event,HaveIt,Link,Thought,WantIt,Item]

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    can :manage, User, :id => user.id
    can :manage, ITEMS, :user_id => user.id
    can :read, ITEMS, :public => true
    can :read, ITEMS if user.id.present?
    can :read, User
  end
end
