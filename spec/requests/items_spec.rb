require 'spec_helper'


describe "Items" do

  before(:each) do
    @user = Factory(:user)
  end

  describe "Get items with various expiration dates" do
    it "renders an item with no expiration without error" do
      item = Factory(:have_it, expires_on: nil, :user => @user, :tag_list => 'icecream')
      get "#{have_its_path}/#{item.id}"
      response.body.should have_selector('h1.itemTitle')
      response.body.should_not have_selector('.expired-notice')
    end

    it "pulls an item that expires in the future without flagging it as expired" do
      item = Factory(:have_it, expires_on: 1.day.from_now, :user => @user, :tag_list => 'icecream')
      get "#{have_its_path}/#{item.id}"
      response.body.should have_selector('h1.itemTitle')
      response.body.should_not have_selector('.expired-notice')
    end

    it "pulls an expired item and shows the expired item notice" do
      item = Factory(:have_it, expires_on: 2.days.ago, :user => @user, :tag_list => 'icecream')
      get "#{have_its_path}/#{item.id}"
      response.body.should have_selector('h1.itemTitle')
      response.body.should have_selector('.expired-notice')
    end
  end
end
