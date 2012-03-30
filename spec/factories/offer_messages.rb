FactoryGirl.define do
  factory :offer_message do
    offer { |a| a.association(:offer) }
    text "Something less than random"

    after_build { |offer_message| offer_message.user_id = offer_message.offer.user.id }
  end

  factory :offer_message_without_user, :class => 'offer_message' do
    offer { |a| a.association(:offer) }
    text "Something less than random"
  end
end
