require 'spec_helper'

describe NotificationsController do
  describe 'GET index' do
    it 'should be successful when logged in' do
      rec = Factory(:recommendation)
      sign_in rec.item.user
      get :index
      response.should be_success
      assigns(:notifications).count.should == 1
    end

    it 'should redirect when not logged in' do
      get :index
      response.should be_redirect
    end
  end
end
