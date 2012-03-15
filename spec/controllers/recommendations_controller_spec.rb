require 'spec_helper'

describe RecommendationsController do
  describe 'CREATE recommendation' do
    it 'should succeed' do
      item = Factory(:item)
      user = Factory(:user)
      sign_in user
      post :create, :item_id => item.id, :recommendation => {:description => 'This is awesome!'}, :format => 'json'
      response.should be_success
      item.recommendations.count.should == 1
    end
  end
end
