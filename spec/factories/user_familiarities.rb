# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user_familiarity do
    user { |a| a.association(:user) }
    familiar { |a| a.association(:user) }
    familiarness 0
  end
end
