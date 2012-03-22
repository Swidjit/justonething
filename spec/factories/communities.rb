# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :community do
    sequence(:name) {|n| "Community #{n}"}
    description "Something random"
    user { |a| a.association(:user) }
  end

  factory :private_community, :parent => :community, do
    is_public false
  end
end
