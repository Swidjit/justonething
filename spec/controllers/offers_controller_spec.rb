require 'spec_helper'

describe OffersController do
  describe "an existing offer" do
    before(:each) do
      @offer = Factory(:offer)
    end

    it "should be visibile to its owner" do
      sign_in @offer.user
      get :index, :item_id => @offer.item.id
      response.should be_success
    end

    it "should be visibile to its item's owner" do
      sign_in @offer.item.user
      get :index, :item_id => @offer.item.id, :user_id => @offer.user.id
      response.should be_success
    end

    it "should be not be visible to other users" do
      sign_in Factory(:user)
      get :index, :item_id => @offer.item.id, :user_id => @offer.user.id
      response.should_not be_success
    end
  end
end
