require 'spec_helper'

describe OfferMessage do
  it "requires text" do
    Factory.build(:offer_message, :text => "").should_not be_valid
  end
end

