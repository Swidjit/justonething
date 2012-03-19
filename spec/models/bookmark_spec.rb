require 'spec_helper'

describe Bookmark do
  describe "a bookmark" do
    it "should only allow user to create a bookmark for an item once" do
      bookmark = Factory(:bookmark)
      Factory.build(:bookmark, :item => bookmark.item, :user => bookmark.user).should be_invalid
    end
  end
end
