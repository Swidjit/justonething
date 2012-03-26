require 'spec_helper'

describe Offer do
  it "should only belong to a user who does not own the item" do
    item = Factory(:have_it)
    Factory.build(:offer, :item => item, :user => item.user).should_not be_valid
  end

  it "should delete any offer_messages when it is destroyed" do
    offer = Factory(:offer)

    Factory(:offer_message, :offer => offer)
    OfferMessage.all.count.should == 1

    offer.destroy
    OfferMessage.all.count.should == 0
  end

  it "should prevent a user from creating more than one offer per item" do
    offer = Factory(:offer)
    Factory.build(:offer, :item => offer.item, :user => offer.user).should be_invalid
  end

  it "should only allow offers for appropriate item classes" do
    all_item_classes = Item.send(:subclasses)
    allow_offers_item_classes = [HaveIt,WantIt]
    do_not_allow_offers_item_classes = all_item_classes - allow_offers_item_classes

    allow_offers_item_classes.each do |item_class|
      item_sym = item_class.to_s.underscore.to_sym
      Factory.build(:offer, :item => Factory(item_sym)).should be_valid
    end

    do_not_allow_offers_item_classes.each do |item_class|
      item_sym = item_class.to_s.underscore.to_sym
      Factory.build(:offer, :item => Factory(item_sym)).should_not be_valid
    end
  end
end
