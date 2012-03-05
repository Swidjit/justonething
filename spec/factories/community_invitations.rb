# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :community_invitation do
    association(:invitee)
    association(:inviter)
    association(:community)
  end
end
