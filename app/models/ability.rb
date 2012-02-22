class Ability
  include CanCan::Ability

  ITEMS = [Event,HaveIt,Link,Thought,WantIt,Item]

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    can :manage, ITEMS << User, :user_id => user.id
    can :read, ITEMS, :public => true
    can :read, User
  end
end
