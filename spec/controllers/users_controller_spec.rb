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
        before(:each) do
          @user = Factory(:user)
          sign_in @user
          get :show, :display_name => @user.display_name
        end

        it "should not display add delegat link" do
          response.body.should_not =~ /add as delegate/
        end

        it "should not display delegates if none are present" do
          response.body.should_not =~ /delegates/
        end

        it "should display delegates if one is present" do
          delegation = Factory(:delegate, :delegator => @user, :delegatee => @target_user)
          get :show, :display_name => @user.display_name # update response to reflect new object
          response.body.should =~ /delegates/
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

      it "logged in user viewing their delegate's profile should see remove as delegate link" do
        delegation = Factory(:delegate, :delegatee => @target_user)
        sign_in delegation.delegator
        get :show, :display_name => @target_user.display_name

        response.body.should =~ /remove as delegate/
      end
    end
  end

  describe 'GET references' do
    before(:each) { @target_user = Factory(:user) }

    it "should find appropriate items" do
      tagged_desc = "This is at @#{@target_user.display_name}"
      item1 = Factory(:thought, :description => tagged_desc)
      item2 = Factory(:want_it)
      item3 = Factory(:have_it, :active => false, :description => tagged_desc)

      sign_in @target_user
      get :references, :id => @target_user.id
      response.should be_success
      assigns(:feed_items).length.should == 1
    end
  end
end
