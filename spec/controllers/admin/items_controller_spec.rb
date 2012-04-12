require 'spec_helper'

describe Admin::ItemsController do
  context "a logged in admin" do
    before(:each) do
      request.env["HTTP_REFERER"] = "/"

      @user = Factory(:user, :is_admin => true)
      sign_in @user

      @item = Factory(:item)
      @item.flag!(Factory(:user))
    end

    it "can view flagged listing" do
      get :flagged
      response.should be_success
    end

    it "can view flagged listing" do
      put :disable, :item_id => @item.id
      response.should be_redirect
    end
  end
end
