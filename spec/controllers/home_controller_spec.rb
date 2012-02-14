require File.dirname(__FILE__) + '/../spec_helper'

describe HomeController do
  describe "GET index" do
    it "should redirect to login" do
      get :index
      response.should be_redirect
    end

    it "should be success" do
      user = Factory(:user)
      sign_in user
      get :index
      response.should be_success
    end
  end
end