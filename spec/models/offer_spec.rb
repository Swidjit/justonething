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

  it "should send an e-mail when an offer is created" do
    original_size = ActionMailer::Base.deliveries.size

    offer = Factory(:offer)
    ActionMailer::Base.deliveries.size.should == original_size + 1

    Factory(:offer_message, :offer => offer, :user => offer.user)
    ActionMailer::Base.deliveries.size.should == original_size + 1
  end

  it "#for_user" do
    item = Factory(:have_it)
    Offer.for_user(item.user).count.should == 0

    Factory(:offer, :item => item)
    Offer.for_user(item.user).count.should == 1

    Factory(:offer, :item => item)
    Offer.for_user(item.user).count.should == 2

    Factory(:offer, :item => Factory(:have_it, :user => item.user))
    Offer.for_user(item.user).count.should == 3
  end
end
