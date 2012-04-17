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
    start_time '07:00 AM'
    end_time '07:00 PM'
    end_date '12/21/2012'
    start_date '12/21/2012'
    end_datetime '2012-12-21 07:00 pm'
    start_datetime '2012-12-21 07:00 am'
  end

  factory :have_it, :parent => :item, :class => 'have_it' do
    cost '3 Sheep'
    condition 'New'
  end

  factory :link, :parent => :item, :class => 'link' do
    link 'http://example.com'
  end

  factory :thought, :parent => :item, :class => 'thought' do
  end

  factory :collection, :parent => :item, :class => 'collection' do
  end
end