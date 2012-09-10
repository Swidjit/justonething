class Ability
  include CanCan::Ability

  ITEMS = [Event,HaveIt,Link,Thought,WantIt,Item,Collection]

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    if user.persisted?
      if user.is_admin
        can :manage, [ItemPresetTag, ITEMS, User].flatten
      end

      can :manage, Comment, :user_id => user.id
      can :manage, User, :id => user.id
      can :manage, ITEMS, :user_id => user.id
      can :manage, ITEMS, :posted_by_user_id => user.id
      can :manage, Community, :user_id => user.id
      can :create, Community
      can :read, ITEMS, :active => true
      can :manage, List, :user_id => user.id
      can :manage, Bookmark, :user_id => user.id
      can :manage, Rsvp, :user_id => user.id
      can :manage, Vouch, :voucher_id => user.id
      can :read, Notification, :receiver_id => user.id
      can :manage, Reminder, :user_id => user.id
      

      # Any member of a community can issue an invite if it's a public group
      can :create, CommunityInvitation, :community => { :id => user.community_ids, :is_public => true }
      # The creator of the community can issue invites regardless of public/private
      can :create, CommunityInvitation, :community => { :user_id => user.id }
      can :destroy, Community, :community => { :user_id => user.id }
      can :read_items, Community, :id => user.community_ids
      can [:accept,:decline], CommunityInvitation, :invitee_id => user.id, :status => 'P'

      can [:read, :update], Offer, :user_id => user.id
      can [:read, :update, :destroy], Offer, :item => { :user_id => user.id }
      cannot :create, Offer, :item => { :user_id => user.id }
      can :recommend, Item do |item|
        item.user != user && !item.recommendations.collect(&:user_id).include?(user.id)
      end
    else
      cannot :create, :all
      cannot :recommend, Item
      cannot :join, Community
      cannot :read, Notification
      can :read, ITEMS, :active => true
      can :read_items, Community, :is_public => true
    end
    can :read, User
    can :read, Comment
    can :read, Community
  end
end
