require 'spec_helper'

describe Admin::UsersController do
  context "a logged in admin" do
    before(:each) do
      request.env["HTTP_REFERER"] = "/"

      @user = Factory(:user, :is_admin => true)
      sign_in @user
    end

    it "can view user listing" do
      get :index
      response.should be_success
    end

    it "can delete a user" do
      delete :destroy, :id => Factory(:user).id
      response.should be_redirect
    end

    it "can activate a user" do
      put :confirm, :id => Factory(:user).id
      response.should be_redirect
    end
  end
end
