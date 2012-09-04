# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :suggested_item do
    item_id 1
    message "MyText"
    user_id 1
    suggested_user_id 1
  end
end
