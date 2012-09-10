# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :custom_feed_subscriptions do
    user_id 1
    custom_feed_id 1
    frequency 1
  end
end
