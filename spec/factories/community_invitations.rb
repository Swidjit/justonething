# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :community_invitation do |ci|
    invitee_display_name {|a| a.association(:user).display_name }
    ci.after_build do |invite|
      invite.community = Factory(:community)
      invite.inviter = invite.community.user
    end
  end
end
