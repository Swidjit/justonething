# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :list do
    name 'Cool people'
    user { |a| a.association(:user) }
  end
end
