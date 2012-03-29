# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :open_hours do
    day_of_week "MyString"
    open_time "MyString"
    close_time "MyString"
  end
end
