# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :bookmark do
    user { |a| a.association(:user) }
    item { |a| a.association(:item) }
  end
end
