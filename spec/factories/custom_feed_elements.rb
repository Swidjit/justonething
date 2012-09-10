# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :custom_feed_elements do
    custom_feed_id 1
    element_id 1
    feed_type "MyString"
  end
end
