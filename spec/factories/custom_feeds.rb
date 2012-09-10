# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :custom_feed do
    user_id 1
    feed_name "MyString"
    feed_type "MyString"
  end
end
