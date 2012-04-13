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

    context "can see a list of their bookmarks" do
      before(:each) do
        Factory(:bookmark, :user => @user)
        get :index
      end

      it "should be a 200" do
        response.status.should == 200
      end

      it "should set an instance variable" do
        assigns(:feed_items).total_entries.should == 1
      end
    end
  end
end
