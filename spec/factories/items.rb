FactoryGirl.define do
  factory :item do
    title 'Important Item'
    description 'This item is very important'
  end

  factory :want_it, :parent => :item, :class => 'want_it' do
  end

  factory :have_it, :parent => :item, :class => 'have_it' do
    cost '3 Sheep'
    condition 'Rough'
  end
end