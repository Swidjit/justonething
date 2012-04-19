# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :city do
    sequence(:url_name) {|n| "city#{n}" }
    sequence(:display_name) {|n| "City #{n}" }
  end
end
