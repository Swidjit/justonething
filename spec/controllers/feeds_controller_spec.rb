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
end
