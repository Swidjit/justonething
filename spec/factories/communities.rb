# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :community do
    sequence(:name) {|n| "Community #{n}"}
    description "Something random"
    user { |a| a.association(:user) }
  end
end
