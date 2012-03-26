FactoryGirl.define do
  factory :offer_message do
    offer { |a| a.association(:offer) }
    text "Something less than random"
  end
end
