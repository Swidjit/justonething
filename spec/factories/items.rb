FactoryGirl.define do
  factory :item do
    title 'Important Item'
    description 'This item is very important'
  end

  factory :have_it, :parent => :item do
    cost '3 Sheep'
    condition 'Rough'
  end
end