require 'spec_helper'

describe RsvpsController do
  context "a logged in user" do
    before(:each) do
      request.env["HTTP_REFERER"] = "/"

      @user = Factory(:user)
      sign_in @user
    end

    it "can rsvp for an event" do
      post :create, :item_id => Factory(:event).id
      @user.rsvps.count.should == 1
    end

    it "can remove an rsvp" do
      delete :destroy, :id => Factory(:rsvp, :user => @user).id
      @user.rsvps.count.should == 0
    end

    it "cannot rsvp for another item type" do
      post :create, :item_id => Factory(:thought).id
      @user.rsvps.count.should == 0
    end
  end
end
