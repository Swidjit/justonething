# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :feed do
    user { |a| a.association(:user) }
    name "My Feed"
    url "http://www.google.com/calendar/ical/ju6l13rier0b6t6cm8bn7r4fvo%40group.calendar.google.com/public/basic.ics"
    last_read_at 5.days.ago
    tag_list 'gardens,muppets'
    geo_tag_list 'dryden,ithaca'
  end
end
