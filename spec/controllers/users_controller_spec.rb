require File.dirname(__FILE__) + '/../spec_helper'

describe UsersController do
  describe "GET show" do
    before(:each) { @target_user = Factory(:user) }

    it "should be visible by guest" do
      get :show, :display_name => @target_user.display_name
      response.should be_success
    end

    context "with render views" do
      render_views

      context "logged in user view own profile" do
        it "should not display add delegat link" do
          response.body.should_not =~ /add as delegate/
        end
      end

      context "logged in user viewing other's profile" do
        before(:each) do
          sign_in Factory(:user)
          get :show, :display_name => @target_user.display_name
        end

        it "should be successful" do
          response.should be_success
        end

        it "should display a link to add the user as a delegate" do
          response.body.should =~ /add as delegate/
        end
      end
    end
  end
end
