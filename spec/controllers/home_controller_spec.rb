require File.dirname(__FILE__) + '/../spec_helper'

describe HomeController do
  describe "GET index" do
    it "should be success for visitor" do
      get :index
      response.should be_success
    end

    it "should be success signed in user" do
      user = Factory(:user)
      sign_in user
      get :index
      response.should be_success
    end
  end
end