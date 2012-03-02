class Ability
  include CanCan::Ability

  ITEMS = [Event,HaveIt,Link,Thought,WantIt,Item]

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    if user.persisted?
      can :manage, User, :id => user.id
      can :manage, ITEMS, :user_id => user.id
      can :manage, Community, :user_id => user.id
      can :create, Community
      can :read, ITEMS, :active => true
    else
      cannot :create, :all
      cannot :join, Community
      can :read, ITEMS, :public => true, :active => true
    end
    can :read, User
    can :read, Community
  end
end
