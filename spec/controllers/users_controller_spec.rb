require File.dirname(__FILE__) + '/../spec_helper'

describe UsersController do
  describe "GET show" do
    before(:each) { @target_user = Factory(:user) }

    it "should be visible by guest" do
      get :show, :display_name => @target_user.display_name
      response.should be_success
    end

    it "should be visible by logged in user" do
      sign_in Factory(:user)
      get :show, :display_name => @target_user.display_name
      response.should be_success
    end
  end
end
