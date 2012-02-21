require File.dirname(__FILE__) + '/../spec_helper'

describe UsersController do
  describe "GET show" do
    it "should redirect to login" do
      get :show, :id => 0
      response.should be_redirect
    end

    it "should be success for own user id" do
      user = Factory(:user)
      sign_in user
      get :show, :id => user.id
      response.should be_success
    end

    it "should be success for other user id" do
      sign_in Factory(:user)
      other_user = Factory(:user)
      get :show, :id => other_user.id
      response.should be_success
    end
  end
end
