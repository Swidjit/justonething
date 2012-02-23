FactoryGirl.define do
  factory :item do
    title 'Important Item'
    description 'This item is very important'
    user { |a| a.association(:user) }
  end

  factory :want_it, :parent => :item, :class => 'want_it' do
  end

  factory :event, :parent => :item, :class => 'event' do
    cost '3 Sheep'
    location 'Stewart Park'
    start_time '2012-12-21 07:00 am'
    end_time '2012-12-21 07:00 pm'
  end

  factory :have_it, :parent => :item, :class => 'have_it' do
    cost '3 Sheep'
    condition 'Rough'
  end

  factory :link, :parent => :item, :class => 'link' do
    link 'http://example.com'
  end

  factory :thought, :parent => :item, :class => 'thought' do
  end
end