FactoryGirl.define do
  factory :user do
    sequence(:email) {|n| "person#{n}@example.com" }
    password 'fakepassword'
    password_confirmation 'fakepassword'
    confirmed_at Time.now
  end
end