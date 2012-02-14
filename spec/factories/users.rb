FactoryGirl.define do
  factory :user do
    sequence(:email) {|n| "person#{n}@example.com" }
    password 'fakepassword'
    password_confirmation 'fakepassword'
    confirmed_at Time.now
    sequence(:display_name) {|n| "Diplay#{n}" }
    first_name 'Joe'
    last_name 'Smith'
    is_thirteen 1
  end
end