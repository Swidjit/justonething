require 'spec_helper'

describe OfferMessage do
  it "requires text" do
    Factory.build(:offer_message, :text => "").should_not be_valid
  end

  it "shouldn't notify item owner if first message" do
    offer_message = Factory(:offer_message)
    # There should be only one notification that is sent from the Offer
    offer_message.offer.item.user.notifications.count.should == 1
  end

  it "should notifiy offer creator when item owner replies" do
    original = Factory(:offer_message)

    original.user.id.should_not == original.offer.item.user.id

    reply = Factory(:offer_message_without_user, :offer => original.offer, :user_id => original.offer.item.user.id)

    original.offer.item.user.notifications.count.should == 1
    original.user.notifications.count.should == 1
  end

  it "should notify item owner when offer creator replies" do
    original = Factory(:offer_message)
    reply = Factory(:offer_message_without_user, :offer => original.offer, :user_id => original.user.id)
    # 1 from original message and 1 from reply
    original.offer.item.user.notifications.count.should == 2
  end
end
