require 'spec_helper'

describe OffersController do
  describe "an existing offer" do
    before(:each) { @offer = Factory(:offer) }

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

  describe "creating an offer" do
    before(:each) do
      request.env["HTTP_REFERER"] = "/"
      @item = Factory(:have_it)
    end

    it "should create an offer and a message if user does not own the item" do
      sign_in Factory(:user)
      post :create, :item_id => @item.id, :text => 'hi, imma buy yo stuff'
      Offer.all.count.should == 1
      OfferMessage.all.count.should == 1
    end

    it "should do nothing for the user who owns the item" do
      sign_in @item.user
      post :create, :item_id => @item.id, :text => 'hi, I am trying to doing something I should not be able to do'
      Offer.all.count.should == 0
      OfferMessage.all.count.should == 0
    end
  end
end
