# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :rsvp do
    user { |a| a.association(:user) }
    item { |a| a.association(:event) }
  end
end
