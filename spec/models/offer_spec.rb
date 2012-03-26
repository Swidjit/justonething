require 'spec_helper'

describe Offer do
  it "should only belong to a user who does not own the item" do
    item = Factory(:item)
    Factory.build(:offer, :item => item, :user => item.user).should_not be_valid
  end

  it "should delete any offer_messages when it is destroyed" do
    offer = Factory(:offer)

    Factory(:offer_message, :offer => offer)
    OfferMessage.all.count.should == 1

    offer.destroy
    OfferMessage.all.count.should == 0
  end
end
