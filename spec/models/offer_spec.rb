require 'spec_helper'

describe Offer do
  it "should only belong to a user who does not own the item" do
    item = Factory(:item)
    Factory.build(:offer, :item => item, :user => item.user).should_not be_valid
  end
end
