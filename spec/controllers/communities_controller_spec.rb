require 'spec_helper'

describe CommunitiesController do
  describe 'create new' do
    it 'should redirect GET new when not logged in' do
      get :new
      response.should be_redirect
    end

    it 'should GET new successfully when logged in' do
      user = Factory(:user)
      sign_in user
      get :new
      response.should be_success
    end

    it 'should successfully create group and set current user as user' do
      user = Factory(:user)
      sign_in user
      post :create, :community => { :name => 'Fake Comm'}
      Community.count.should == 1
      Community.first.user.should == user
    end

    it 'should GET show successfully' do
      c = Factory(:community)
      get :show, :id => c.id
      response.should be_success
    end
  end
end
