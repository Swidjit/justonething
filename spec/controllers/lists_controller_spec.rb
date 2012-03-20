require 'spec_helper'

describe ListsController do
  describe 'Creating a list' do
    it 'should successfully create' do
      user = Factory(:user)
      sign_in user
      post :create, :list => { :name => 'Mario Party' }, :format => :json
      user.lists.count.should == 1
    end
  end

  describe 'Adding a user' do
    it 'should successfully add a user to their list and should update familiarity' do
      list = Factory(:list)
      user_to_add = Factory(:user)

      sign_in list.user
      post :add_user, :user_id => user_to_add.id, :id => list.id, :format => :json
      ActiveSupport::JSON.decode(response.body)["success"].should == true
      UserFamiliarity.find_all_by_user_id_and_familiar_id(list.user_id,user_to_add.id).count.should == 1
    end

    it 'should fail to add a user to a list that is not theirs' do
      list = Factory(:list)
      other_user = Factory(:user)
      user_to_add = Factory(:user)

      sign_in other_user
      post :add_user, :user_id => user_to_add.id, :id => list.id, :format => :json
      ActiveSupport::JSON.decode(response.body)["success"].should == false
    end
  end

  describe 'Removing a user' do
    it 'should successfully remove a user from their list and should update familiarity' do
      list = Factory(:list)
      user_to_remove = Factory(:user)
      list.users << user_to_remove

      sign_in list.user
      post :delete_user, :user_id => user_to_remove.id, :id => list.id, :format => :json
      ActiveSupport::JSON.decode(response.body)["success"].should == true
      UserFamiliarity.find_all_by_user_id_and_familiar_id(list.user_id,user_to_remove.id).first.familiarness.should == 0
    end
  end

  describe 'Viewing a list' do
    it 'should load for the creator' do
      list = Factory(:list)
      sign_in list.user
      get :show, :id => list.id
      response.should be_success
    end

    it 'should redirect for anyone else' do
      list = Factory(:list)
      other_user = Factory(:user)
      sign_in other_user
      get :show, :id => list.id
      response.should be_redirect
    end
  end
end
