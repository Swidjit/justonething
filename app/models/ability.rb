class Ability
  include CanCan::Ability

  ITEMS = [Event,HaveIt,Link,Thought,WantIt,Item]

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    if user.persisted?
      if user.is_admin
        can :manage, ItemPresetTag
      end
      can :manage, Comment, :user_id => user.id
      can :manage, User, :id => user.id
      can :manage, ITEMS, :user_id => user.id
      can :manage, Community, :user_id => user.id
      can :create, Community
      can :read, ITEMS, :active => true
      can :manage, List, :user_id => user.id
      can :manage, Bookmark, :user_id => user.id
      can :manage, Vouch, :voucher_id => user.id

      # Any member of a community can issue an invite if it's a public group
      can :create, CommunityInvitation, :community => { :id => user.community_ids, :is_public => true }
      # The creator of the community can issue invites regardless of public/private
      can :create, CommunityInvitation, :community => { :user_id => user.id }
      can [:accept,:decline], CommunityInvitation, :invitee_id => user.id, :status => 'P'
    else
      cannot :create, :all
      cannot :join, Community
      can :read, ITEMS, :public => true, :active => true
    end
    can :read, User
    can :read, Comment
    can :read, Community
  end
end
