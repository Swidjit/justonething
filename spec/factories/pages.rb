# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :page do
    body "MyText"
    user_id 1
    position 1
    active false
  end
end
