require 'spec_helper'

shared_examples "an item with offers controller" do
  render_views

  before(:each) do
    @object_sym = @controller.controller_name.singularize.to_sym
    @object_attributes = Factory.attributes_for(@object_sym, :expires_on => 2.days.from_now.strftime('%m/%d/%Y'))
    @object_attributes.delete(:user)
  end

  describe "offers" do
    before(:each) { @item = Factory(@object_sym) }

    describe "a logged in user looking at their own item" do
      before(:each) { sign_in @item.user }

      it "should let the user know when no offers exist" do
        get :show, :id => @item.id
        response.should be_success
        response.body.should =~ /No offers yet./
      end

      it "should display the offers if it has any" do
        Factory(:offer, :item => @item)
        get :show, :id => @item.id
        response.should be_success
        response.body.should =~ /offer_heading/
      end
    end

    describe "a logged in user looking at another user's item" do
      before(:each) do
        @other_user = Factory(:user)
        sign_in @other_user
      end

      it "should display the create form if not already created" do
        get :show, :id => @item.id
        response.should be_success
        response.body.should =~ /send offer/
      end

      it "should display the reply form if already created" do
        Factory(:offer, :user => @other_user, :item => @item)
        get :show, :id => @item.id
        response.should be_success
        response.body.should =~ /reply/
      end
    end
  end
end
