class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    can :manage, [Event,HaveIt,Link,Thought,WantIt,User], :user_id => user.id
    can :read, :all
  end
end
