FactoryGirl.define do
  factory :offer do
    user { |a| a.association(:user) }
    item { |a| a.association(:item) }
  end
end
