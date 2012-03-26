require 'spec_helper'

describe OffersController do
  describe "a logged in user" do
    before(:each) do
      @item = Factory(:have_it)
      @user = Factory(:user)
    end

    it "should be able to create an offer on an item" do
      post :create, :item_id => @item.id
      Offer.all.count.should == 1
    end
  end
end
