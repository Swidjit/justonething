require 'spec_helper'

shared_examples "an item controller" do
  render_views

  describe "the new item form" do
    it "should not show the user_id select if the user is not a delagatee" do
      sign_in Factory(:user)
      get :new
      response.body.should_not =~ /Post As/
    end

    it "should show the user_id select if the user is a delegatee" do
      delegatee = Factory(:user)
      Factory(:delegate, :delegatee => delegatee)
      sign_in delegatee
      get :new
      response.body.should =~ /Post As/
    end
  end

  describe "adding a new item" do
    before(:each) do
      @object_sym = @controller.controller_name.singularize.to_sym
      @object_attributes = Factory.attributes_for(@object_sym, :expires_on => 2.days.from_now.strftime('%m/%d/%Y'))
      @object_attributes.delete(:user)
    end

    it "should not allow a user to set the user_id to not one of their delegates" do
      @object_attributes[:user_id] = Factory(:user).id

      sign_in Factory(:user)
      post :create, @object_sym => @object_attributes

      Item.count.should == 0
    end

    it "should allow a user to set the user_id to one of their delegates" do
      delegation = Factory(:delegate)
      @object_attributes[:user_id] = delegation.delegator.id

      sign_in delegation.delegatee
      post :create, @object_sym => @object_attributes

      Item.count.should == 1
      Item.first.user.should == delegation.delegator
      Item.first.posted_by_user.should == delegation.delegatee
    end
  end
end
