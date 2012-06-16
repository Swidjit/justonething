# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :reminder do
    user { |a| a.association(:user) }
    item { |a| a.association(:event) }
    date nil
    sent_on nil
  end
end
