require 'spec_helper'

describe OfferMessagesController do
  describe "an existing offer" do
    before(:each) do
      request.env["HTTP_REFERER"] = "/"
      @offer = Factory(:offer)
    end

    it "should be writable by the owner" do
      sign_in @offer.user
      post :create, :offer_id => @offer.id, :offer_message => { :text => 'hello' }
      OfferMessage.all.count.should == 1
    end

    it "should be writable by the item owner" do
      sign_in @offer.item.user
      post :create, :offer_id => @offer.id, :offer_message => { :text => 'hello' }
      OfferMessage.all.count.should == 1
    end

    it "should not be writable by another user" do
      sign_in Factory(:user)
      post :create, :offer_id => @offer.id, :offer_message => { :text => 'hello' }
      OfferMessage.all.count.should == 0
    end
  end
end
