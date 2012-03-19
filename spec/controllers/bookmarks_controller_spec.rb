require 'spec_helper'

describe BookmarksController do
  context "a logged in user" do
    before(:each) do
      request.env["HTTP_REFERER"] = "/"

      @user = Factory(:user)
      sign_in @user
    end

    it "can bookmark an item" do
      post :create, :item_id => Factory(:item).id
      @user.bookmarks.count.should == 1
    end

    it "can destroy a bookmark" do
      delete :destroy, :id => Factory(:bookmark, :user => @user).id
      @user.bookmarks.count.should == 0
    end
  end
end
