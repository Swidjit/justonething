# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :delegate do
    delegator { |a| a.association(:user) }
    delegatee { |a| a.association(:user) }
  end
end
