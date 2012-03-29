# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :recommendation do
    user { |a| a.association(:user) }
    item { |a| a.association(:have_it) }
    description 'This is awesome!'
  end
end
