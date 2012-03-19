require 'spec_helper'

describe Bookmark do
  describe "a bookmark" do
    it "should only allow user to create a bookmark for an item once" do
      bookmark = Factory(:bookmark)
      Factory.build(:bookmark, :item => bookmark.item, :user => bookmark.user).should be_invalid
    end
  end

  describe "retrieving bookmarks" do
    it "should be filterable by user" do
      bk1 = Factory(:bookmark)
      bk2 = Factory(:bookmark)

      Bookmark.for_user(bk1.user).should == [bk1]
      Bookmark.for_user(bk2.user).should == [bk2]
    end
  end
end
