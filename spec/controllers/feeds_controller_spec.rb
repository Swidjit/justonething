require 'spec_helper'

describe FeedsController do
  describe "GET tag" do
    it 'should only load tagged item' do
      user = Factory(:user)
      item = Factory(:thought, :user => user, :tag_list => 'ice cream')
      sign_in user
      get :tag, :tag_name => 'ice cream'
      assigns(:feed_items).should == [item]
      get :tag, :tag_name => 'elephant'
      assigns(:feed_items).should == []
    end
  end

  describe 'GET specific item type' do
    it 'should only load items of the correct type' do
      user = Factory(:user)
      thought = Factory(:thought, :user => user)
      want_it = Factory(:want_it, :user => user)
      sign_in user
      get :thoughts
      assigns(:feed_items).should == [thought]
      get :want_its
      assigns(:feed_items).should == [want_it]
    end
  end
end
