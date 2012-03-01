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
  end

  describe 'view' do
    it 'should GET show successfully' do
      c = Factory(:community)
      get :show, :id => c.id
      response.should be_success
    end
  end

  describe 'joining' do
    it 'should successfully add a user to the community' do
      user = Factory(:user)
      com = Factory(:community)
      sign_in user
      post :join, :id => com.id
      response.should be_redirect
      com.reload
      com.users.should include(user)
    end

    it 'should not add a user that is not logged in' do
      com = Factory(:community)
      post :join, :id => com.id
      response.should be_redirect
      com.reload
      com.users.count.should == 1 #The creator
    end
  end

  describe 'leaving' do
    it 'should successfully remove a user if they are not the creator' do
      com = Factory(:community)
      usr = Factory(:user)
      com.users << usr
      com.save
      com.users.count.should == 2
      sign_in com.user
      delete :leave, :id => com.id
      response.should be_redirect
      com.reload
      com.users.count.should == 2

      sign_out com.user

      sign_in usr
      delete :leave, :id => com.id
      response.should be_redirect
      com.reload
      com.users.count.should == 1
    end
  end
end
